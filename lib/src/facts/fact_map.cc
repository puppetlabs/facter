#include <facts/fact_map.hpp>
#include <algorithm>

using namespace std;

namespace cfacter { namespace facts {

    fact_map fact_map::_instance;

    void fact_map::add_fact(fact&& f)
    {
        // Search for the fact first
        auto const& it = _facts.lower_bound(f.name());
        if (it != _facts.end() && !(_facts.key_comp()(f.name(), it->first))) {
            throw fact_exists_exception("fact " + f.name() + " already exists.");
        }

        // Remove any resolver for this fact and add the fact
        _resolvers.erase(f.name());
        _facts.insert(it, std::make_pair(f.name(), std::move(f)));
    }

    void fact_map::remove(string const& name)
    {
        _facts.erase(name);
    }

    void fact_map::clear()
    {
        _facts.clear();
        _resolvers.clear();
    }

    bool fact_map::empty() const
    {
        return _facts.empty() && _resolvers.empty();
    }

    fact const* fact_map::get_fact(std::string const& name)
    {
        load();

        auto it = _facts.find(name);
        if (it == _facts.end()) {
            // Check the resolvers
            auto const& resolver_it = _resolvers.find(name);
            if (resolver_it == _resolvers.end()) {
                // Fact not found
                return nullptr;
            }
            auto resolver = resolver_it->second;

            // Resolve the facts
            resolver->resolve(*this);

            // Remove any associated facts that didn't resolve
            for (auto const& name : resolver->names()) {
                _resolvers.erase(name);
            }

            it = _facts.find(name);
            if (it == _facts.end()) {
                // Fact not found after resolution
                return nullptr;
            }
        }
        return &it->second;
    }


    void fact_map::each(std::function<bool(std::string const&, value const*)> func)
    {
        load();
        resolve_facts();

        std::find_if(begin(_facts), end(_facts), [&func](fact_map_type::value_type const& it) {
            return func(it.first, it.second.val());
        });
    }

    fact_map& fact_map::instance()
    {
        return fact_map::_instance;
    }

    void fact_map::load()
    {
        if (!empty()) {
            return;
        }
        populate_common_facts();
        populate_platform_facts();
    }

    void fact_map::resolve_facts()
    {
        // Go through every resolver and get each fact
        while (!_resolvers.empty())
        {
            // Copy the string from the key as resolving the facts will
            // destruct the resolver entry in the map
            string name = _resolvers.begin()->first;
            get_fact(name);
        }
    }

}}  // namespace cfacter::facts
