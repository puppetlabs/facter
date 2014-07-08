/**
 * @file
 * Declares the fact map.
 */
#ifndef FACTER_FACTS_FACT_MAP_HPP_
#define FACTER_FACTS_FACT_MAP_HPP_

#include <list>
#include <map>
#include <set>
#include <vector>
#include <string>
#include <memory>
#include <functional>
#include <stdexcept>
#include <iostream>

namespace facter { namespace facts {

    // Forward declare the value and resolver types
    struct value;
    struct resolver;

    /**
     * Thrown when a fact already has an associated resolver.
     */
    struct resolver_exists_exception : std::runtime_error
    {
        /**
         * Constructs a resolver_exists_exception.
         * @param message The exception message.
         */
        explicit resolver_exists_exception(std::string const& message);
    };

    /**
     * Represents the fact map.
     * The fact map is responsible for resolving and storing facts.
     */
    struct fact_map
    {
        /**
         * Constructs a fact_map.
         */
        fact_map();

        /**
         * Destructor for fact_map.
         */
        ~fact_map();

        /**
         * Adds a resolver to the fact map.
         * @param res The resolver to add to the map.
         */
        void add(std::shared_ptr<resolver> const& res);

        /**
         * Adds a fact to the map.
         * @param name The name of the fact.
         * @param value The value of the fact.
         */
        void add(std::string&& name, std::unique_ptr<value>&& value);

        /**
         * Removes a resolver from the fact map.
         * @param res The resolver to remove from the map.
         */
        void remove(std::shared_ptr<resolver> const& res);

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
         * @return Returns true if the fact map is empty or false if it is not.
         */
        bool empty() const;

        /**
         * Checks to see if the fact map has been resolved.
         * @return Returns true if all fact resolvers have been resolved or false if at least one fact resolver remains unresolved.
         */
        bool resolved() const;

        /**
         * Gets the size of the fact map.
         * @return Returns the number of resolved top-level facts in the fact map.
         */
        size_t size() const;

        /**
         * Resolves all facts.
         * This forces each resolver in the map to resolve.
         * @param facts The set of fact names to filter the resolution to.  If empty, all facts will be resolved.
         */
        void resolve(std::set<std::string> const& facts = std::set<std::string>());

        /**
        * Resolves all external facts into the  fact map.
        * @param directories The directories to search for external facts.
        * @param facts The set of fact names to filter the resolution to.  If empty, all external facts will be resolved.
        */
        void resolve_external(std::vector<std::string> const& directories = {}, std::set<std::string> const& facts = std::set<std::string>());

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
        value const* operator[](std::string const& name);

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

        /**
         * Writes the contents of the fact map as YAML to the given stream.
         * @param stream The stream to write the YAML to.
         */
        void write_yaml(std::ostream& stream) const;

     private:
        typedef std::map<std::string, std::unique_ptr<value>> fact_map_type;
        typedef std::map<std::string, std::shared_ptr<resolver>> resolver_map_type;

        friend std::ostream& operator<<(std::ostream& os, fact_map const& facts);

        std::shared_ptr<resolver> find_resolver(std::string const& name);
        value const* get_value(std::string const& name, bool resolve);

        fact_map_type _facts;
        std::list<std::shared_ptr<resolver>> _resolvers;
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

