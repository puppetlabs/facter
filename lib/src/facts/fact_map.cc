#include <facter/facts/fact_map.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/logging/logging.hpp>
#include <algorithm>
#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>

using namespace std;
using namespace rapidjson;

LOG_DECLARE_NAMESPACE("facts.map");

namespace facter { namespace facts {

    /**
     * Called to populate common facts.
     * @param facts The fact map being populated.
     */
    extern void populate_common_facts(fact_map& facts);

    /**
     * Called to populate platform-specific facts.
     * @param facts The fact map being populated.
     */
    extern void populate_platform_facts(fact_map& facts);

    fact_map::fact_map()
    {
        populate_common_facts(*this);
        populate_platform_facts(*this);
    }

    void fact_map::add(shared_ptr<fact_resolver> const& resolver)
    {
        if (!resolver) {
            return;
        }

        for (auto const& fact_name : resolver->names()) {
            auto const& it = _resolver_map.lower_bound(fact_name);
            if (it != _resolver_map.end() && !(_resolver_map.key_comp()(fact_name, it->first))) {
                throw resolver_exists_exception("a resolver for fact " + fact_name + " already exists.");
            }
            _resolver_map.insert(it, make_pair(fact_name, resolver));
        }
        _resolvers.push_back(resolver);
    }

    void fact_map::add(string&& name, unique_ptr<value>&& value)
    {
        // Search for the fact first
        auto const& it = _facts.lower_bound(name);
        if (it != _facts.end() && !(_facts.key_comp()(name, it->first))) {
            throw fact_exists_exception("fact " + name + " already exists.");
        }

        if (LOG_IS_DEBUG_ENABLED()) {
            ostringstream ss;
            if (value) {
                ss << *value;
            } else {
                ss << "<null>";
            }
            LOG_DEBUG("fact %1% has resolved to \"%2%\".", name, ss.str());
        }

        // Remove any mapped resolver for this fact
        _resolver_map.erase(name);
        _facts.insert(it, make_pair(move(name), move(value)));
    }

    void fact_map::remove(shared_ptr<fact_resolver> const& resolver)
    {
        if (!resolver) {
            return;
        }

        // Remove all fact associations
        for (auto const& name : resolver->names()) {
            if (LOG_IS_DEBUG_ENABLED()) {
                auto it = _facts.find(name);
                if (it == _facts.end()) {
                    LOG_DEBUG("fact %1% was not resolved.", name);
                }
            }
            _resolver_map.erase(name);
        }
        _resolvers.remove(resolver);
    }

    void fact_map::remove(string const& name)
    {
        _resolver_map.erase(name);
        _facts.erase(name);
    }

    void fact_map::clear()
    {
        _facts.clear();
        _resolvers.clear();
        _resolver_map.clear();
    }

    bool fact_map::empty() const
    {
        return _facts.empty() && _resolvers.empty();
    }

    bool fact_map::resolved() const
    {
        return _resolvers.empty();
    }

    void fact_map::resolve(set<string> const& facts)
    {
        if (!facts.empty()) {
            // Resolve the given facts
            for (auto const& fact : facts) {
                if (fact.empty()) {
                    continue;
                }
                auto value = get_value(fact, true);
                if (!value) {
                    LOG_DEBUG("fact %1% was not resolved.", fact);
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
        for (auto& resolver : _resolvers) {
            resolver->resolve(*this);
        }
        _resolvers.clear();

        // Log any facts that didn't resolve
        if (LOG_IS_DEBUG_ENABLED()) {
            for (auto kvp : _resolver_map) {
                auto it = _facts.find(kvp.first);
                if (it == _facts.end()) {
                    LOG_DEBUG("fact %1% was not resolved.", kvp.first);
                }
            }
        }
        _resolver_map.clear();
    }

    void fact_map::each(function<bool(string const&, value const*)> func) const
    {
        find_if(begin(_facts), end(_facts), [&func](fact_map_type::value_type const& it) {
            return func(it.first, it.second.get());
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

    void fact_map::write_json(ostream& stream) const
    {
        Document document;
        document.SetObject();

        for (auto const& kvp : _facts) {
            if (!kvp.second) {
                continue;
            }

            Value value;
            kvp.second->to_json(document.GetAllocator(), value);
            document.AddMember(kvp.first.c_str(), value, document.GetAllocator());
        }

        stream_adapter adapter(stream);
        PrettyWriter<stream_adapter> writer(adapter);
        writer.SetIndent(' ', 2);
        document.Accept(writer);
    }

    value const* fact_map::get_value(string const& name, bool resolve)
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

    shared_ptr<fact_resolver> fact_map::find_resolver(string const& name)
    {
        // Check the map first to see if we know the fact by name
        auto const& it = _resolver_map.find(name);
        if (it != _resolver_map.end()) {
            return it->second;
        }

        // Otherwise, do a linear search for a resolver that can resolve the fact
        for (auto const& resolver : _resolvers) {
            if (resolver->can_resolve(name)) {
                return resolver;
            }
        }
        return nullptr;
    }

    ostream& operator<<(ostream& os, fact_map const& facts)
    {
        // Print all facts in the map
        bool first = true;
        for (auto const& kvp : facts._facts) {
            if (!kvp.second) {
                continue;
            }

            if (first) {
                first = false;
            } else {
                os << '\n';
            }
            os << kvp.first << " => " << *kvp.second;
        }
        return os;
    }

}}  // namespace facter::facts
