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
#include <unordered_map>
#include <vector>
#include <string>
#include <memory>
#include <functional>
#include <stdexcept>
#include <iostream>

namespace facter { namespace facts {

    static const std::string cached_custom_facts("cached-custom-facts");

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

    namespace {
        /**
         * Stream adapter for using with rapidjson
         */
        struct stream_adapter
        {
            /**
             * Constructs an adapter for use with rapidjson around the given stream.
             * @param stream an output stream to which JSON will be written
             */
            explicit stream_adapter(std::ostream& stream) : _stream(stream)
            {
            }

            /**
             * Adds a character to the stream.
             * @param c the char to add
             */
            void Put(char c)
            {
                _stream << c;
            }

            /**
             * Flushes the stream.
             */
            void Flush()
            {
                _stream.flush();
            }

         private:
            std::ostream& _stream;
        };
    }

    /**
     * Represents the fact collection.
     * The fact collection is responsible for resolving and storing facts.
     */
    struct LIBFACTER_EXPORT collection
    {
        /**
         * Inherent "has_weight" value for external facts.
         */
        constexpr static size_t external_fact_weight = 10000;

        /**
         * Constructs a fact collection.
         * @param blocklist the names of resolvers that should not be resolved
         * @param ttls a map of resolver names to cache intervals (times-to-live)
         *        for the facts they resolve
         * @param ignore_cache true if the cache should not be consulted when resolving facts
         */
        collection(std::set<std::string> const& blocklist = std::set<std::string>(),
                   std::unordered_map<std::string, int64_t> const& ttls = std::unordered_map<std::string, int64_t>{},
                   bool ignore_cache = false);

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
         * Adds a custom fact to the fact collection.
         * @param name The name of the fact.
         * @param value The value of the fact.
         * @param weight The weight of the fact.
         */
        void add_custom(std::string name, std::unique_ptr<value> value, size_t weight);

        /**
         * Adds an external fact to the fact collection.
         * @param name The name of the fact.
         * @param value The value of the fact.
         */
        void add_external(std::string name, std::unique_ptr<value> value);

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

        /**
         * Returns the names of all the resolvers currently in the collection,
         * along with their associated facts. The group names are used to allow
         * caching of those facts.
         * @return a map of group names to their associated fact names
         */
        std::map<std::string, std::vector<std::string>> get_fact_groups();

        /**
         * Returns the time-to-live time for each fact from the facter.conf file
         * @return a map of fact names to their associated time-to-live value
         */
        const std::unordered_map<std::string, int64_t>& get_ttls();

        /**
         * Returns the names of all blockable resolvers currently in the collection,
         * along with their associated facts. The group names are used to allow
         * blocking of those facts.
         * @return a map of blockable group names to their associated fact names
         */
        std::map<std::string, std::vector<std::string>> get_blockable_fact_groups();

        /**
         *  Gets external fact groups (practically files names)
         *  @param directories The directories to search for external facts.  If empty, the default search paths will be used.
         * @return a map of group names to their associated fact names (empty)
         */
        std::map<std::string, std::vector<std::string>> get_external_facts_groups(std::vector<std::string> const& directories);

     protected:
        /**
         *  Gets external fact directories for the current platform.
         *  @return A list of file paths that will be searched for external facts.
         */
        virtual std::vector<std::string> get_external_fact_directories() const;

     private:
        typedef std::list<std::pair<std::string, std::shared_ptr<external::resolver>>> external_files_list;
        LIBFACTER_NO_EXPORT void resolve_fact(std::string const& name);
        LIBFACTER_NO_EXPORT value const* get_value(std::string const& name);
        LIBFACTER_NO_EXPORT value const* query_value(std::string const& query, bool strict_errors);
        LIBFACTER_NO_EXPORT value const* lookup(value const* value, std::string const& name, bool strict_errors);
        LIBFACTER_NO_EXPORT void write_hash(std::ostream& stream, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);
        LIBFACTER_NO_EXPORT void write_json(std::ostream& stream, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);
        LIBFACTER_NO_EXPORT void write_yaml(std::ostream& stream, std::set<std::string> const& queries, bool show_legacy, bool strict_errors);
        LIBFACTER_NO_EXPORT void add_common_facts(bool include_ruby_facts);
        LIBFACTER_NO_EXPORT void get_external_facts_files_from_dir(external_files_list& files,
                                                                   std::string const& directory, bool warn);

        LIBFACTER_NO_EXPORT external_files_list get_external_facts_files(std::vector<std::string> const& directories);
        LIBFACTER_NO_EXPORT bool try_block(std::shared_ptr<resolver> const& res);
        LIBFACTER_NO_EXPORT void resolve(std::shared_ptr<resolver> const& res);

        // Platform specific members
        LIBFACTER_NO_EXPORT void add_platform_facts();

        std::map<std::string, std::unique_ptr<value>> _facts;
        std::list<std::shared_ptr<resolver>> _resolvers;
        std::multimap<std::string, std::shared_ptr<resolver>> _resolver_map;
        std::list<std::shared_ptr<resolver>> _pattern_resolvers;
        std::set<std::string> _blocklist;
        std::unordered_map<std::string, int64_t> _ttls;
        bool _ignore_cache;
    };

}}  // namespace facter::facts
