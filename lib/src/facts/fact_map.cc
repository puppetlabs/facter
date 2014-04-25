#include <facts/fact_map.hpp>
#include <logging/logging.hpp>
#include <algorithm>

using namespace std;

LOG_DECLARE_NAMESPACE("facts");

namespace cfacter { namespace facts {

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

    fact_map fact_map::_instance;

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

        LOG_DEBUG("fact %1% has resolved to \"%2%\".", name, value ? value->to_string() : "<null>");

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

    void fact_map::each(function<bool(string const&, value const*)> func)
    {
        load_facts();
        resolve_facts();

        find_if(begin(_facts), end(_facts), [&func](fact_map_type::value_type const& it) {
            return func(it.first, it.second.get());
        });
    }

    fact_map& fact_map::instance()
    {
        return fact_map::_instance;
    }

    void fact_map::load_facts()
    {
        if (!empty()) {
            return;
        }
        populate_common_facts(*this);
        populate_platform_facts(*this);
    }

    void fact_map::resolve_facts()
    {
        for (auto& resolver : _resolvers) {
            resolver->resolve(*this);
        }
        _resolvers.clear();
        _resolver_map.clear();
    }

    value const* fact_map::get_value(string const& name, bool resolve)
    {
        load_facts();

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

}}  // namespace cfacter::facts
