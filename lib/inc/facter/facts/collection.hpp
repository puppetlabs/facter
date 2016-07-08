/**
 * @file
 * Declares the fact collection.
 */
#pragma once

#include "resolver.hpp"
#include "value.hpp"
#include "external/resolver.hpp"
#include "../export.h"
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
    struct LIBFACTER_EXPORT collection
    {
        /**
         * Constructs a fact collection.
         */
        collection();

        /**
         * Destructor for fact collection.
         */
        ~collection();

        /**
         * Prevents the fact collection from being copied.
         */
        collection(collection const&) = delete;

        /**
         * Prevents the fact collection from being copied.
         * @returns Returns this fact collection.
         */
        collection& operator=(collection const&) = delete;

        /**
         * Moves the given fact collection into this fact collection.
         * @param other The fact collection to move into this fact collection.
         */
        // Visual Studio 12 still doesn't allow default for move constructor.
        collection(collection&& other);

        /**
         * Moves the given fact collection into this fact collection.
         * @param other The fact collection to move into this fact collection.
         * @return Returns this fact collection.
         */
        // Visual Studio 12 still doesn't allow default for move assignment.
        collection& operator=(collection&& other);

        /**
         * Adds the default facts to the collection.
         * @param include_ruby_facts Whether or not to include facts which require Ruby in the collection.
         */
        void add_default_facts(bool include_ruby_facts);

        /**
         * Adds a resolver to the fact collection.
         * The last resolver that was added for a particular name or pattern will "win" resolution.
         * @param res The resolver to add to the fact collection.
         */
        void add(std::shared_ptr<resolver> const& res);

        /**
         * Adds a fact to the fact collection.
         * @param name The name of the fact.
         * @param value The value of the fact.
         */
        void add(std::string name, std::unique_ptr<value> value);

        /**
         * Adds external facts to the fact collection.
         * @param directories The directories to search for external facts.  If empty, the default search paths will be used.
         */
        void add_external_facts(std::vector<std::string> const& directories = {});

        /**
         * Adds facts defined via "FACTER_xyz" environment variables.
         * @param callback The callback that is called with the name of each fact added from the environment.
         */
        void add_environment_facts(std::function<void(std::string const&)> callback = nullptr);

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
         * All facts will be resolved to determine if the collection is empty.
         * @return Returns true if the fact collection is empty or false if it is not.
         */
        bool empty();

        /**
         * Gets the count of facts in the fact collection.
         * All facts will be resolved to determine the size of the collection.
         * @return Returns the number of facts in the fact collection.
         */
        size_t size();

        /**
         * Gets a fact value by name.
         * @tparam T The expected type of the value.
         * @param name The name of the fact to get the value of.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the fact collection or the value is not the expected type.
         */
        template <typename T = value>
        T const* get(std::string const& name)
        {
            return dynamic_cast<T const*>(get_value(name));
        }

        /**
        * Gets a fact value by name without resolving the fact.
        * @tparam T The expected type of the value.
        * @param name The name of the fact to get the value of.
        * @return Returns a pointer to the fact value or nullptr if the fact is not resolved or the value is not the expected type.
        */
        template <typename T = value>
        T const* get_resolved(std::string const& name) const
        {
            // Lookup the fact without resolving
            auto it = _facts.find(name);
            return dynamic_cast<T const*>(it == _facts.end() ? nullptr : it->second.get());
        }

        /**
         * Gets a fact value by name
         * @param name The name of the fact to get the value of.
         * @return Returns a pointer to the fact value or nullptr if the fact is not in the fact collection.
         */
        value const* operator[](std::string const& name);

        /**
         * Query the collection.
         * @tparam T The expected type of the value.
         * @param query The query to run.
         * @return Returns the result of the query or nullptr if the query returned no value.
         */
        template <typename T = value>
        T const* query(std::string const& query)
        {
            return dynamic_cast<T const*>(query_value(query, false));
        }

        /**
         * Enumerates all facts in the collection.
         * All facts will be resolved prior to enumeration.
         * @param func The callback function called for each fact in the collection.
         */
        void each(std::function<bool(std::string const&, value const*)> func);

        /**
         * Writes the contents of the fact collection to the given stream, hiding legacy facts.
         * All facts will be resolved prior to writing.
         * @param stream The stream to write the facts to.
         * @param fmt The output format to use.
         * @param queries The set of queries to filter the output to. If empty, all facts will be output.
         * @return Returns the stream being written to.
         */
        std::ostream& write(std::ostream& stream, format fmt = format::hash, std::set<std::string> const& queries = std::set<std::string>());

        /**
         * Writes the contents of the fact collection to the given stream.
         * All facts will be resolved prior to writing.
         * @param stream The stream to write the facts to.
         * @param fmt The output format to use.
         * @param queries The set of queries to filter the output to. If empty, all facts will be output.
         * @param show_legacy Show legacy facts when querying all facts.
         * @param strict_errors Report additional error cases
         * @return Returns the stream being written to.
         */
        std::ostream& write(std::ostream& stream, format fmt, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);

        /**
         * Resolves all facts in the collection.
         */
        void resolve_facts();

     protected:
        /**
         *  Gets external fact directories for the current platform.
         *  @return A list of file paths that will be searched for external facts.
         */
        virtual std::vector<std::string> get_external_fact_directories() const;

     private:
        LIBFACTER_NO_EXPORT void resolve_fact(std::string const& name);
        LIBFACTER_NO_EXPORT value const* get_value(std::string const& name);
        LIBFACTER_NO_EXPORT value const* query_value(std::string const& query, bool strict_errors);
        LIBFACTER_NO_EXPORT value const* lookup(value const* value, std::string const& name, bool strict_errors);
        LIBFACTER_NO_EXPORT void write_hash(std::ostream& stream, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);
        LIBFACTER_NO_EXPORT void write_json(std::ostream& stream, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);
        LIBFACTER_NO_EXPORT void write_yaml(std::ostream& stream, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);
        LIBFACTER_NO_EXPORT void add_common_facts(bool include_ruby_facts);
        LIBFACTER_NO_EXPORT bool add_external_facts_dir(std::vector<std::unique_ptr<external::resolver>> const& resolvers, std::string const& directory, bool warn);

        // Platform specific members
        LIBFACTER_NO_EXPORT void add_platform_facts();
        LIBFACTER_NO_EXPORT std::vector<std::unique_ptr<external::resolver>> get_external_resolvers();

        std::map<std::string, std::unique_ptr<value>> _facts;
        std::list<std::shared_ptr<resolver>> _resolvers;
        std::multimap<std::string, std::shared_ptr<resolver>> _resolver_map;
        std::list<std::shared_ptr<resolver>> _pattern_resolvers;
    };

}}  // namespace facter::facts
