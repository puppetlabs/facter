#ifndef FACTER_FACTS_FACT_MAP_HPP_
#define FACTER_FACTS_FACT_MAP_HPP_

#include <list>
#include <map>
#include <set>
#include <string>
#include <memory>
#include <functional>
#include <stdexcept>
#include <iostream>
#include "value.hpp"
#include "fact_resolver.hpp"

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
        /**
         * Constructs a fact_map.
         */
        fact_map();

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
         * This will remove all built-in facts and resolvers from the map.
         */
        void clear();

        /**
         * Checks to see if the fact map is empty.
         * @return Returns true if the fact map is entry or false if it is not.
         */
        bool empty() const;

        /**
         * Checks to see if the fact map has been resolved.
         * @return Returns true if all fact resolvers have been resolved or false if at least fact resolver remains unresolved.
         */
        bool resolved() const;

        /**
         * Resolves all facts.
         * This forces each resolver in the map to resolve.
         * @param facts The set of fact names to filter the resolution to.  If empty, all facts will be resolved.
         */
        void resolve(std::set<std::string> const& facts = std::set<std::string>());

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
        void each(std::function<bool(std::string const&, value const*)> func) const;

        /**
         * Writes the contents of the fact map as JSON to the given stream.
         * @param stream The stream to write the JSON to.
         */
        void write_json(std::ostream& stream) const;

     private:
        typedef std::map<std::string, std::unique_ptr<value>> fact_map_type;
        typedef std::map<std::string, std::shared_ptr<fact_resolver>> resolver_map_type;

        friend std::ostream& operator<<(std::ostream& os, fact_map const& facts);

        std::shared_ptr<fact_resolver> find_resolver(std::string const& name);
        value const* get_value(std::string const& name, bool resolve);

        fact_map_type _facts;
        std::list<std::shared_ptr<fact_resolver>> _resolvers;
        resolver_map_type _resolver_map;
    };

    /**
     * Insertion operator for fact_map.
     * @param os The output stream to write to.
     * @param facts The facts to write to the stream.
     * @return Returns the given output stream.
     */
    std::ostream& operator<<(std::ostream& os, fact_map const& facts);

}}  // namespace facter::facts

#endif  // FACTER_FACTS_FACT_MAP_HPP_

