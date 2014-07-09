#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/external/resolver.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <algorithm>
#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace rapidjson;
using namespace YAML;
using namespace boost::filesystem;
namespace bs = boost::system;

LOG_DECLARE_NAMESPACE("facts.collection");

namespace facter { namespace facts {

    /**
     * Called to populate common facts.
     * @param facts The fact collection being populated.
     */
    extern void populate_common_facts(collection& facts);

    /**
     * Called to populate platform-specific facts.
     * @param facts The fact collection being populated.
     */
    extern void populate_platform_facts(collection& facts);

    /**
     * Called to get the external fact search directories for the current platform.
     * @returns Returns the vector of search directories for external facts.
     */
    extern vector<string> get_external_directories();

    /**
     * Called to get the external fact resolvers for the current platform.
     * @returns Returns the vector of external fact resolvers.
     */
    extern vector<unique_ptr<external::resolver>> get_external_resolvers();

    resolver_exists_exception::resolver_exists_exception(string const& message) :
        runtime_error(message)
    {
    }

    collection::collection()
    {
        populate_common_facts(*this);
        populate_platform_facts(*this);
    }

    collection::~collection()
    {
        // This needs to be defined here since we use incomplete types in the header
    }

    void collection::add(shared_ptr<resolver> const& res)
    {
        if (!res) {
            return;
        }

        for (auto const& fact_name : res->names()) {
            auto const& it = _resolver_map.lower_bound(fact_name);
            if (it != _resolver_map.end() && !(_resolver_map.key_comp()(fact_name, it->first))) {
                throw resolver_exists_exception("a resolver for fact \"" + fact_name + "\" already exists.");
            }
            _resolver_map.insert(it, make_pair(fact_name, res));
        }
        _resolvers.push_back(res);
    }

    void collection::add(string&& name, unique_ptr<value>&& value)
    {
        // Search for the fact first
        auto const& it = _facts.lower_bound(name);
        if (it != _facts.end() && !(_facts.key_comp()(name, it->first))) {
            if (!value) {
                LOG_DEBUG("fact \"%1%\" resolved to null and the existing value will be removed.", name);
                _facts.erase(it);
                return;
            }
            if (LOG_IS_DEBUG_ENABLED()) {
                ostringstream old_value;
                ostringstream new_value;
                old_value << *it->second;
                new_value << *value;
                LOG_DEBUG("fact \"%1%\" has changed from \"%2%\" to \"%3%\".", name, old_value.str(), new_value.str());
            }
            it->second = move(value);
        } else {
            if (!value) {
                LOG_DEBUG("fact \"%1%\" resolved to null and will not be added.", name);
                return;
            }
            if (LOG_IS_DEBUG_ENABLED()) {
                ostringstream ss;
                ss << *value;
                LOG_DEBUG("fact \"%1%\" has resolved to \"%2%\".", name, ss.str());
            }
            _facts.insert(it, make_pair(move(name), move(value)));
        }

        // Remove any mapped resolver for this fact
        _resolver_map.erase(name);
    }

    void collection::remove(shared_ptr<resolver> const& res)
    {
        if (!res) {
            return;
        }

        // Remove all fact associations
        for (auto const& name : res->names()) {
            if (LOG_IS_DEBUG_ENABLED()) {
                auto it = _facts.find(name);
                if (it == _facts.end()) {
                    LOG_DEBUG("fact \"%1%\" was not resolved.", name);
                }
            }
            _resolver_map.erase(name);
        }
        _resolvers.remove(res);
    }

    void collection::remove(string const& name)
    {
        _resolver_map.erase(name);
        _facts.erase(name);
    }

    void collection::clear()
    {
        _facts.clear();
        _resolvers.clear();
        _resolver_map.clear();
    }

    bool collection::empty() const
    {
        return _facts.empty() && _resolvers.empty();
    }

    bool collection::resolved() const
    {
        return _resolvers.empty();
    }

    size_t collection::size() const
    {
        return _facts.size();
    }

    void collection::resolve(set<string> const& facts)
    {
        if (resolved()) {
            return;
        }
        if (!facts.empty()) {
            // Resolve the given facts
            for (auto const& fact : facts) {
                if (fact.empty()) {
                    continue;
                }
                auto value = get_value(fact, true);
                if (!value) {
                    // For parity with Ruby facter, add an empty string
                    LOG_DEBUG("fact \"%1%\" was requested but not resolved; adding empty string value.", fact);
                    add(string(fact), make_value<string_value>(""));
                }
            }

            // Remove facts that resolved but aren't in the filter
            for (auto it = _facts.begin(); it != _facts.end();) {
                if (facts.count(it->first)) {
                    // In the requested set of facts so move next
                    ++it;
                    continue;
                }
                it = _facts.erase(it);
            }
            return;
        }

        // No filter given, resolve all facts
        for (auto& res : _resolvers) {
            res->resolve(*this);
        }
        _resolvers.clear();

        // Log any facts that didn't resolve
        if (LOG_IS_DEBUG_ENABLED()) {
            for (auto kvp : _resolver_map) {
                auto it = _facts.find(kvp.first);
                if (it == _facts.end()) {
                    LOG_DEBUG("fact \"%1%\" was not resolved.", kvp.first);
                }
            }
        }
        _resolver_map.clear();
    }

    void collection::resolve_external(vector<string> const& directories, set<string> const& facts)
    {
        vector<unique_ptr<external::resolver>> resolvers = get_external_resolvers();

        auto search_directories = directories;
        if (search_directories.empty()) {
            search_directories = get_external_directories();
        }

        // Build a map between a file and the resolver that can resolve it
        map<string, external::resolver const*> files;
        for (auto const& directory : search_directories) {
            directory_iterator end;
            directory_iterator it;

            // Attempt to iterate the directory
            try {
                it = directory_iterator(directory);
            } catch (filesystem_error& ex) {
                // Warn the user if not using the default search directories
                if (!directories.empty()) {
                    LOG_WARNING("skipping external facts for \"%1%\": %2%", directory, ex.code().message());
                } else {
                    LOG_DEBUG("skipping external facts for \"%1%\": %2%", directory, ex.code().message());
                }
                continue;
            }

            LOG_DEBUG("searching \"%1%\" for external facts.", directory);

            // Search for regular files in the directory
            for (; it != end; ++it) {
                bs::error_code ec;
                if (!is_regular_file(it->status())) {
                    continue;
                }

                string path = it->path().string();

                for (auto const& res : resolvers) {
                    if (res->can_resolve(path)) {
                        files.emplace(path, res.get());
                        break;
                    }
                }
            }
        }

        // Resolve the files
        for (auto const& kvp : files) {
            try
            {
                kvp.second->resolve(kvp.first, *this);
            }
            catch (external::external_fact_exception& ex) {
                LOG_ERROR("error while processing \"%1%\" for external facts: %2%", kvp.first, ex.what());
            }
        }

        // Remove facts that resolved but aren't in the filter
        if (!facts.empty()) {
            for (auto it = _facts.begin(); it != _facts.end();) {
                if (facts.count(it->first)) {
                    // In the requested set of facts so move next
                    ++it;
                    continue;
                }
                it = _facts.erase(it);
            }
        }
    }

    value const* collection::operator[](string const& name)
    {
        return get_value(name, true);
    }

    void collection::each(function<bool(string const&, value const*)> func) const
    {
        find_if(begin(_facts), end(_facts), [&func](map<string, unique_ptr<value>>::value_type const& it) {
            return !func(it.first, it.second.get());
        });
    }

    struct stream_adapter
    {
        explicit stream_adapter(ostream& stream) : _stream(stream)
        {
        }

        void Put(char c)
        {
            _stream << c;
        }

     private:
         ostream& _stream;
    };

    ostream& collection::write(ostream& stream, format fmt) const
    {
        if (fmt == format::hash) {
            write_hash(stream);
        } else if (fmt == format::json) {
            write_json(stream);
        } else if (fmt == format::yaml) {
            write_yaml(stream);
        }
        return stream;
    }

    value const* collection::get_value(string const& name, bool resolve)
    {
        // Lookup the fact
        auto it = _facts.find(name);
        while (it == _facts.end()) {
            // Look for a resolver for this fact
            auto resolver = resolve ? find_resolver(name) : nullptr;
            if (!resolver) {
                return nullptr;
            }

            // Resolve the facts
            resolver->resolve(*this);
            remove(resolver);

            // Try to find the fact again
            it = _facts.find(name);
        }
        return it->second.get();
    }

    void collection::write_hash(ostream& stream) const
    {
        // If there's only one fact, print it without the name
        if (_facts.size() == 1) {
            stream << *_facts.begin()->second;
            return;
        }

        // Print all facts in the map
        bool first = true;
        for (auto const& kvp : _facts) {
            if (first) {
                first = false;
            } else {
                stream << '\n';
            }
            stream << kvp.first << " => " << *kvp.second;
        }
    }

    void collection::write_json(ostream& stream) const
    {
        Document document;
        document.SetObject();

        for (auto const& kvp : _facts) {
            rapidjson::Value value;
            kvp.second->to_json(document.GetAllocator(), value);
            document.AddMember(kvp.first.c_str(), value, document.GetAllocator());
        }

        stream_adapter adapter(stream);
        PrettyWriter<stream_adapter> writer(adapter);
        writer.SetIndent(' ', 2);
        document.Accept(writer);
    }

    void collection::write_yaml(ostream& stream) const
    {
        Emitter emitter(stream);
        emitter << BeginMap;
        for (auto const& kvp : _facts) {
            emitter << Key << kvp.first;
            emitter << YAML::Value << *kvp.second;
        }
        emitter << EndMap;
    }

    shared_ptr<resolver> collection::find_resolver(string const& name)
    {
        // Check the map first to see if we know the fact by name
        auto const& it = _resolver_map.find(name);
        if (it != _resolver_map.end()) {
            return it->second;
        }

        // Otherwise, do a linear search for a resolver that can resolve the fact
        for (auto const& res : _resolvers) {
            if (res->can_resolve(name)) {
                return res;
            }
        }
        return nullptr;
    }

}}  // namespace facter::facts
