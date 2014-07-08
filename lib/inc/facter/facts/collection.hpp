/**
 * @file
 * Declares the fact collection.
 */
#ifndef FACTER_FACTS_COLLECTION_HPP_
#define FACTER_FACTS_COLLECTION_HPP_

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
     * The supported output format for the fact collection.
     */
    enum class format
    {
        /**
         * Use ruby "hash" as the format (default).
         */
        hash,
        /**
         * Use JSON as the format.
         */
        json,
        /**
         * Use YAML as the format.
         */
        yaml
    };

    /**
     * Represents the fact collection.
     * The fact collection is responsible for resolving and storing facts.
     */
    struct collection
    {
        /**
         * Constructs a fact collection.
         */
        collection();

        /**
         * Destructor for collection.
         */
        ~collection();

        /**
         * Adds a resolver to the fact collection.
         * @param res The resolver to add to the fact collection.
         */
        void add(std::shared_ptr<resolver> const& res);

        /**
         * Adds a fact to the fact collection.
         * @param name The name of the fact.
         * @param value The value of the fact.
         */
        void add(std::string&& name, std::unique_ptr<value>&& value);

        /**
         * Removes a resolver from the fact collection.
         * @param res The resolver to remove from the fact collection.
         */
        void remove(std::shared_ptr<resolver> const& res);

        /**
         * Removes a fact by name.
         * @param name The name of the fact to remove.
         */
        void remove(std::string const& name);

        /**
         * Clears the entire fact collection.
         * This will remove all built-in facts and resolvers from the fact collection.
         */
        void clear();

        /**
         * Checks to see if the fact collection is empty.
         * @return Returns true if the fact collection is empty or false if it is not.
         */
        bool empty() const;

        /**
         * Checks to see if the fact collection has been resolved.
         * @return Returns true if all fact resolvers have been resolved or false if at least one fact resolver remains unresolved.
         */
        bool resolved() const;

        /**
         * Gets the size of the fact collection.
         * @return Returns the number of resolved top-level facts in the fact collection.
         */
        size_t size() const;

        /**
         * Resolves all facts.
         * This forces each resolver in the fact collection to resolve.
         * @param facts The set of fact names to filter the resolution to.  If empty, all facts will be resolved.
         */
        void resolve(std::set<std::string> const& facts = std::set<std::string>());

        /**
        * Resolves all external facts into the fact collection.
        * @param directories The directories to search for external facts.
        * @param facts The set of fact names to filter the resolution to.  If empty, all external facts will be resolved.
        */
        void resolve_external(std::vector<std::string> const& directories = {}, std::set<std::string> const& facts = std::set<std::string>());

        /**
         * Gets a fact value by name.
         * @tparam T The expected type of the value.
         * @param name The name of the fact to get the value of.
         * @param resolve True if resolution should take place or false if not.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the fact collection or the value is not the expected type.
         */
        template <typename T>
        T const* get(std::string const& name, bool resolve = true)
        {
            return dynamic_cast<T const*>(get_value(name, resolve));
        }

        /**
         * Gets a fact value by name
         * @param name The name of the fact to get the value of.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the fact collection.
         */
        value const* operator[](std::string const& name);

        /**
         * Enumerates all facts in the fact collection.
         * @param func The callback function called for each fact in the fact collection.
         */
        void each(std::function<bool(std::string const&, value const*)> func) const;

        /**
         * Writes the contents of the fact collection to the given stream.
         * @param stream The stream to write the facts to.
         * @param fmt The output format to use.
         * @return Returns the stream being written to.
         */
        std::ostream& write(std::ostream& stream, format fmt = format::hash) const;

     private:
        std::shared_ptr<resolver> find_resolver(std::string const& name);
        value const* get_value(std::string const& name, bool resolve);
        void write_hash(std::ostream& stream) const;
        void write_json(std::ostream& stream) const;
        void write_yaml(std::ostream& stream) const;

        std::map<std::string, std::unique_ptr<value>> _facts;
        std::list<std::shared_ptr<resolver>> _resolvers;
        std::map<std::string, std::shared_ptr<resolver>> _resolver_map;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_COLLECTION_HPP_

