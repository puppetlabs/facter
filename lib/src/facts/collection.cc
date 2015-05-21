#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/string.hpp>
#include <facter/version.h>
#include <internal/util/dynamic_library.hpp>
#include <internal/facts/resolvers/ruby_resolver.hpp>
#include <internal/facts/resolvers/path_resolver.hpp>
#include <internal/facts/resolvers/ec2_resolver.hpp>
#include <internal/facts/resolvers/gce_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>
#include <yaml-cpp/yaml.h>
#include <algorithm>

using namespace std;
using namespace facter::util;
using namespace rapidjson;
using namespace YAML;
using namespace boost::filesystem;

namespace facter { namespace facts {

    collection::collection()
    {
        // This needs to be defined here since we use incomplete types in the header
    }

    collection::~collection()
    {
        // This needs to be defined here since we use incomplete types in the header
    }

    collection::collection(collection&& other)
    {
        *this = std::move(other);
    }

    collection& collection::operator=(collection&& other)
    {
        if (this != &other) {
            _facts = std::move(other._facts);
            _resolvers = std::move(other._resolvers);
            _resolver_map = std::move(other._resolver_map);
            _pattern_resolvers = std::move(other._pattern_resolvers);
        }
        return *this;
    }

    void collection::add_default_facts()
    {
        add_common_facts();
        add_platform_facts();
    }

    void collection::add(shared_ptr<resolver> const& res)
    {
        if (!res) {
            return;
        }

        for (auto const& name : res->names()) {
            _resolver_map.insert({ name, res });
        }

        if (res->has_patterns()) {
            _pattern_resolvers.push_back(res);
        }

        _resolvers.push_back(res);
    }

    void collection::add(string name, unique_ptr<value> value)
    {
        // Ensure the fact is resolved before replacing it
        auto old_value = get_value(name);

        if (LOG_IS_DEBUG_ENABLED()) {
            if (old_value) {
                ostringstream old_value_ss;
                old_value->write(old_value_ss);
                if (!value) {
                    LOG_DEBUG("fact \"%1%\" resolved to null and the existing value of %2% will be removed.", name, old_value_ss.str());
                } else {
                    ostringstream new_value_ss;
                    value->write(new_value_ss);
                    LOG_DEBUG("fact \"%1%\" has changed from %2% to %3%.", name, old_value_ss.str(), new_value_ss.str());
                }
            } else {
                if (!value) {
                    LOG_DEBUG("fact \"%1%\" resolved to null and will not be added.", name);
                } else {
                    ostringstream new_value_ss;
                    value->write(new_value_ss);
                    LOG_DEBUG("fact \"%1%\" has resolved to %2%.", name, new_value_ss.str());
                }
            }
        }

        if (!value) {
            if (old_value) {
                remove(name);
            }
            return;
        }

        _facts[move(name)] = move(value);
    }

    void collection::add_external_facts(vector<string> const& directories)
    {
        auto resolvers = get_external_resolvers();

        auto search_directories = directories;
        if (search_directories.empty()) {
            search_directories = get_external_fact_directories();
        }

        // Build a map between a file and the resolver that can resolve it
        bool found = false;
        for (auto const& dir : search_directories) {
            // If dir is relative, make it an absolute path before passing to can_resolve.
            boost::system::error_code ec;
            path search_dir = canonical(dir, ec);

            if (ec || !is_directory(search_dir, ec)) {
                // Warn the user if not using the default search directories
                string msg = ec ? ec.message() : "not a directory";
                if (!directories.empty()) {
                    LOG_WARNING("skipping external facts for \"%1%\": %2%", dir, msg);
                } else {
                    LOG_DEBUG("skipping external facts for \"%1%\": %2%", dir, msg);
                }
                continue;
            }

            LOG_DEBUG("searching %1% for external facts.", search_dir);

            directory::each_file(search_dir.string(), [&](string const& path) {
                for (auto const& res : resolvers) {
                    if (res->can_resolve(path)) {
                        try {
                            found = true;
                            res->resolve(path, *this);
                        }
                        catch (external::external_fact_exception& ex) {
                            LOG_ERROR("error while processing \"%1%\" for external facts: %2%", path, ex.what());
                        }
                        break;
                    }
                }
                return true;
            });
        }

        if (!found) {
            LOG_DEBUG("no external facts were found.");
        }
    }

    void collection::add_environment_facts(function<void(string const& name)> callback)
    {
        environment::each([&](string& name, string& value) {
            // If the variable starts with "FACTER_", the remainder of the variable is the fact name
            if (!boost::istarts_with(name, "FACTER_")) {
                return true;
            }

            auto fact_name = name.substr(7);
            boost::to_lower(fact_name);
            LOG_DEBUG("setting fact \"%1%\" based on the value of environment variable \"%2%\".", fact_name, name);

            // Add the value based on the environment variable
            add(fact_name, make_value<string_value>(move(value)));
            if (callback) {
                callback(fact_name);
            }
            return true;
        });
    }

    void collection::remove(shared_ptr<resolver> const& res)
    {
        if (!res) {
            return;
        }

        // Remove all name associations
        for (auto const& name : res->names()) {
            auto range = _resolver_map.equal_range(name);
            auto it = range.first;
            while (it != range.second) {
                if (it->second != res) {
                    ++it;
                    continue;
                }
                it = _resolver_map.erase(it);
            }
        }

        _pattern_resolvers.remove(res);
        _resolvers.remove(res);
    }

    void collection::remove(string const& name)
    {
        // Ensure the fact is in the collection
        // This will properly resolve the fact prior to removing it
        if (!get_value(name)) {
            return;
        }

        _facts.erase(name);
    }

    void collection::clear()
    {
        _facts.clear();
        _resolvers.clear();
        _resolver_map.clear();
        _pattern_resolvers.clear();
    }

    bool collection::empty()
    {
        return _facts.empty() && _resolvers.empty();
    }

    size_t collection::size()
    {
        resolve_facts();
        return _facts.size();
    }

    value const* collection::operator[](string const& name)
    {
        return get_value(name);
    }

    void collection::each(function<bool(string const&, value const*)> func)
    {
        resolve_facts();

        find_if(begin(_facts), end(_facts), [&func](map<string, unique_ptr<value>>::value_type const& it) {
            return !func(it.first, it.second.get());
        });
    }

    ostream& collection::write(ostream& stream, format fmt, set<string> const& queries)
    {
        if (queries.empty()) {
            // Resolve all facts
            resolve_facts();
        }

        if (fmt == format::hash) {
            write_hash(stream, queries);
        } else if (fmt == format::json) {
            write_json(stream, queries);
        } else if (fmt == format::yaml) {
            write_yaml(stream, queries);
        }
        return stream;
    }

    void collection::resolve_facts()
    {
        // Remove the front of the resolvers list and resolve until no resolvers are left
        while (!_resolvers.empty()) {
            auto resolver = _resolvers.front();
            remove(resolver);
            LOG_DEBUG("resolving %1% facts.", resolver->name());
            resolver->resolve(*this);
        }
    }

    void collection::resolve_fact(string const& name)
    {
        // Resolve every resolver mapped to this name first
        auto range = _resolver_map.equal_range(name);
        auto it = range.first;
        while (it != range.second) {
            auto resolver = (it++)->second;
            remove(resolver);
            LOG_DEBUG("resolving %1% facts.", resolver->name());
            resolver->resolve(*this);
        }

         // Resolve every resolver that matches the given name
        auto pattern_it = _pattern_resolvers.begin();
        while (pattern_it != _pattern_resolvers.end()) {
            if (!(*pattern_it)->is_match(name)) {
                ++pattern_it;
                continue;
            }
            auto resolver = *(pattern_it++);
            remove(resolver);
            LOG_DEBUG("resolving %1% facts.", resolver->name());
            resolver->resolve(*this);
        }
    }

    value const* collection::get_value(string const& name)
    {
        resolve_fact(name);

        // Lookup the fact
        auto it = _facts.find(name);
        return it == _facts.end() ? nullptr : it->second.get();
    }

    value const* collection::query_value(string const& query)
    {
        // First attempt to lookup a fact with the exact name of the query
        value const* current = get_value(query);
        if (current) {
            return current;
        }

        bool in_quotes = false;
        string segment;
        for (auto const& c : query) {
            if (c == '"') {
                in_quotes = !in_quotes;
                continue;
            }
            if (in_quotes || c != '.') {
                segment += c;
                continue;
            }
            current = lookup(current, segment);
            if (!current) {
                return nullptr;
            }
            segment.clear();
        }

        if (!segment.empty()) {
            current = lookup(current, segment);
        }
        return current;
    }

    value const* collection::lookup(value const* value, string const& name)
    {
        if (!value) {
            value = get_value(name);
            if (!value) {
                LOG_DEBUG("fact \"%1%\" does not exist.", name);
            }
            return value;
        }

        auto map = dynamic_cast<map_value const*>(value);
        if (map) {
            value = (*map)[name];
            if (!value) {
                LOG_DEBUG("cannot lookup a hash element with \"%1%\": element does not exist.", name);
            }
            return value;
        }

        auto array = dynamic_cast<array_value const*>(value);
        if (array) {
            int index;
            try {
                index = stoi(name);
            } catch (logic_error&) {
                LOG_DEBUG("cannot lookup an array element with \"%1%\": expected an integral value.", name);
                return nullptr;
            }
            if (index < 0) {
                LOG_DEBUG("cannot lookup an array element with \"%1%\": expected a non-negative value.", name);
                return nullptr;
            }
            if (array->empty()) {
                LOG_DEBUG("cannot lookup an array element with \"%1%\": the array is empty.", name);
                return nullptr;
            }
            if (static_cast<size_t>(index) >= array->size()) {
                LOG_DEBUG("cannot lookup an array element with \"%1%\": expected an integral value between 0 and %2% (inclusive).", name, array->size() - 1);
                return nullptr;
            }
            return (*array)[index];
        }
        return nullptr;
    }

    void collection::write_hash(ostream& stream, set<string> const& queries)
    {
        // If there's only one query, print the result without the name
        if (queries.size() == 1u) {
            auto value = query_value(*queries.begin());
            if (value) {
                value->write(stream, false);
            }
            return;
        }

        bool first = true;
        auto writer = ([&](string const& key, value const* val) {
            // Ignore facts with hidden values
            if (queries.empty() && val && val->hidden()) {
                return;
            }
            if (first) {
                first = false;
            } else {
                stream << '\n';
            }
            stream << key << " => ";
            if (val) {
                val->write(stream, false);
            }
        });

        if (!queries.empty()) {
            // Print queried facts
            vector<pair<string, value const*>> facts;
            for (auto const& query : queries) {
                facts.push_back(make_pair(query, this->query_value(query)));
            }

            for (auto const& kvp : facts) {
                writer(kvp.first, kvp.second);
            }
        } else {
            // Print all facts in the map
            for (auto const& kvp : _facts) {
                writer(kvp.first, kvp.second.get());
            }
        }
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

    void collection::write_json(ostream& stream, set<string> const& queries)
    {
        Document document;
        document.SetObject();

        auto builder = ([&](string const& key, value const* val) {
            // Ignore facts with hidden values
            if (queries.empty() && val && val->hidden()) {
                return;
            }
            rapidjson::Value value;
            if (val) {
                val->to_json(document.GetAllocator(), value);
            } else {
                value.SetString("", 0);
            }
            document.AddMember(key.c_str(), value, document.GetAllocator());
        });

        if (!queries.empty()) {
            for (auto const& query : queries) {
                builder(query, this->query_value(query));
            }
        } else {
            for (auto const& kvp : _facts) {
                builder(kvp.first, kvp.second.get());
            }
        }

        stream_adapter adapter(stream);
        PrettyWriter<stream_adapter> writer(adapter);
        writer.SetIndent(' ', 2);
        document.Accept(writer);
    }

    void collection::write_yaml(ostream& stream, set<string> const& queries)
    {
        Emitter emitter(stream);
        emitter << BeginMap;

        auto writer = ([&](string const& key, value const* val) {
            // Ignore facts with hidden values
            if (queries.empty() && val && val->hidden()) {
                return;
            }
            emitter << Key;
            if (needs_quotation(key)) {
                emitter << DoubleQuoted;
            }
            emitter << key << YAML::Value;
            if (val) {
                val->write(emitter);
            } else {
                emitter << DoubleQuoted << "";
            }
        });

        if (!queries.empty()) {
            vector<pair<string, value const*>> facts;
            for (auto const& query : queries) {
                facts.push_back(make_pair(query, this->query_value(query)));
            }

            for (auto const& kvp : facts) {
                writer(kvp.first, kvp.second);
            }
        } else {
            for (auto const& kvp : _facts) {
                writer(kvp.first, kvp.second.get());
            }
        }
        emitter << EndMap;
    }

    void collection::add_common_facts()
    {
        add("facterversion", make_value<string_value>(LIBFACTER_VERSION));
        add(make_shared<resolvers::ruby_resolver>());
        add(make_shared<resolvers::path_resolver>());
        add(make_shared<resolvers::ec2_resolver>());
        add(make_shared<resolvers::gce_resolver>());
    }

}}  // namespace facter::facts
