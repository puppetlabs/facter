#ifndef LIB_INC_FACTS_FACT_MAP_HPP_
#define LIB_INC_FACTS_FACT_MAP_HPP_

#include <vector>
#include <map>
#include <string>
#include <memory>
#include <functional>
#include "value.hpp"
#include "fact_resolver.hpp"

namespace cfacter { namespace facts {

    struct fact_map;

    /**
     * Called to populate common facts.
     * @param facts The fact map being populated.
     */
    void populate_common_facts(fact_map& facts);

    /**
     * Called to populate platform-specific facts.
     * @param facts The fact map being populated.
     */
    void populate_platform_facts(fact_map& facts);

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
         * Constructs a resolver_exists_exception.
         * @param message The exception message.
         */
        explicit resolver_exists_exception(std::string const& message) : std::runtime_error(message) {}
    };

    /**
     * Represents the fact map.
     */
    struct fact_map
    {
        typedef std::map<std::string, std::unique_ptr<value>> fact_map_type;
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
         * @param name The name of the fact.
         * @param value The value of the fact.
         */
        void add(std::string&& name, std::unique_ptr<value>&& value);

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
         * Gets a fact value by name.
         * @param name The name of the fact to get the value of.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the map or the value is not the expected type.
         */
        template <typename T>
        T const* get(std::string const& name)
        {
            return dynamic_cast<T const*>(get_value(name));
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
        fact_map() {}
        void load();
        void resolve_facts();
        value const* get_value(std::string const& name);

        static fact_map _instance;

        fact_map_type _facts;
        resolver_map_type _resolvers;
    };

}}  // namespace cfacter::facts

#endif  // LIB_INC_FACTS_FACT_MAP_HPP_

