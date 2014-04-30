#ifndef FACTER_FACTS_FACT_MAP_HPP_
#define FACTER_FACTS_FACT_MAP_HPP_

#include <list>
#include <map>
#include <string>
#include <memory>
#include <functional>
#include "value.hpp"
#include "fact_resolver.hpp"
#include <stdexcept>

namespace facter { namespace facts {

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
         * Adds a resolver to the fact map.
         * @param resolver The resolver to add to the map.
         */
        void add(std::shared_ptr<fact_resolver> const& resolver);


        /**
         * Adds a fact to the map.
         * @param name The name of the fact.
         * @param value The value of the fact.
         */
        void add(std::string&& name, std::unique_ptr<value>&& value);

        /**
         * Removes a resolver from the fact map.
         * @param resolver The resolver to remove from the map.
         */
        void remove(std::shared_ptr<fact_resolver> const& resolver);

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
         * @tparam T The expected type of the value.
         * @param name The name of the fact to get the value of.
         * @param resolve True if resolution should take place or false if not.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the map or the value is not the expected type.
         */
        template <typename T>
        T const* get(std::string const& name, bool resolve = true)
        {
            return dynamic_cast<T const*>(get_value(name, resolve));
        }

        /**
         * Gets a fact value by name
         * @param name The name of the fact to get the value of.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the map.
         */
        value const* operator[](std::string const& name)
        {
            return get_value(name, true);
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
        void load_facts();
        void resolve_facts();
        std::shared_ptr<fact_resolver> find_resolver(std::string const& name);
        value const* get_value(std::string const& name, bool resolve);

        static fact_map _instance;

        fact_map_type _facts;
        std::list<std::shared_ptr<fact_resolver>> _resolvers;
        resolver_map_type _resolver_map;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_FACT_MAP_HPP_

