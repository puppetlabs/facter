#ifndef __FACT_MAP_HPP__
#define	__FACT_MAP_HPP__

#include <vector>
#include <map>
#include <string>
#include <memory>
#include <functional>
#include "value.hpp"
#include "fact.hpp"
#include "fact_resolver.hpp"

namespace cfacter { namespace facts {

    /**
     * Thrown when a fact already exists in the map.
     */
    struct fact_exists_exception : std::runtime_error
    {
        /**
         * Constructs a fact_exists_exception.
         * @param message The exception message.
         */
        explicit fact_exists_exception(std::string const& message) : std::runtime_error(message) {}
    };

    /**
     * Thrown when a fact already has an associated resolver.
     */
    struct resolver_exists_exception : std::runtime_error
    {
        /**
         * Constructs a fact_exists_exception.
         * @param message The exception message.
         */
        explicit resolver_exists_exception(std::string const& message) : std::runtime_error(message) {}
    };

    /**
     * Represents the fact map.
     */
    struct fact_map
    {
        typedef std::map<std::string, fact> fact_map_type;
        typedef std::map<std::string, std::shared_ptr<fact_resolver>> resolver_map_type;

        /**
        * Adds a fact resolver to the fact map.
        * @tparam T The fact resolver type to add to the map.  Must be default-constructable.
        */
        template <typename T>
        void add_resolver()
        {
            std::shared_ptr<fact_resolver> resolver(new T());

            for (auto const& fact_name : resolver->names()) {
                auto const& it = _resolvers.lower_bound(fact_name);
                if (it != _resolvers.end() && !(_resolvers.key_comp()(fact_name, it->first))) {
                    throw resolver_exists_exception("a resolver for fact " + fact_name + " already exists.");
                }
                _resolvers.insert(it, make_pair(fact_name, resolver));
            }
        }

        /**
         * Adds a fact to the map.
         * @param f The fact to add to the map.
         */
        void add_fact(fact&& f);

        /**
         * Removes a fact by name.
         * @param name The name of the fact to remove.
         */
        void remove(std::string const& name);

        /**
         * Clears the entire fact map.
         */
        void clear();

        /**
         * Checks to see if the fact map is empty.
         * @return Returns true if the fact map is entry or false if it is not.
         */
        bool empty() const;

        /**
         * Gets a fact by name.
         * @param name The name of the fact to get.
         * @return Returns a pointer to the fact or nullptr if the fact is not in the map.
         */
        fact const* get_fact(std::string const& name);

        /**
         * Gets a fact value by name.
         * @param name The name of the fact to get the value of.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the map or the value is not the expected type.
         */
        template <typename T>
        T const* get_value(std::string const& name)
        {
            auto f = get_fact(name);
            if (!f) {
                return nullptr;
            }
            return dynamic_cast<T const*>(f->val());
        }

        /**
         * Enumerates all facts in the map.
         * @param func The callback function called for each fact in the map.
         */
        void each(std::function<bool(std::string const&, value const*)> func);

        /**
         * Gets the singleton instance of the fact map.
         * @return Returns the singleton instance of the fact map.
         */
        static fact_map& instance();

    private:
        //fact_map() {}
        void load();
        void resolve_facts();

        static fact_map _instance;

        fact_map_type _facts;
        resolver_map_type _resolvers;
    };

}} // namespace cfacter::facts

#endif

