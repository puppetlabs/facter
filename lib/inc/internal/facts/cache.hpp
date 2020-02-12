#pragma once

#include <facter/facts/collection.hpp>

#include <boost/filesystem.hpp>

namespace facter { namespace facts { namespace cache {

    /**
     * Adds the cached value to the collection if it both exists and
     * has not expired. Otherwise, resolves the value afresh and caches it.
     * @param facts the collection of facts to which to add
     * @param res the resolver that should be cached
     * @param ttl the duration in seconds for which the cahced value is considered valid
     */
    void use_cache(collection& facts, std::shared_ptr<base_resolver> res, int64_t ttl);

    /**
     * Checks the given directory for cached facts of the given names.
     * Each fact found is added to the collection.
     * @param cache_file the JSON cache file associated with this resolver
     * @param cached_facts the names of the facts to search for
     * @param facts to collection of facts to which to add
     */
    void load_facts_from_cache(boost::filesystem::path const& cache_file, std::shared_ptr<base_resolver> res, collection& facts);

    /**
     * Resolve facts from the given resolver and write them out to the cache, one file per resolver.
     * @param res the resolver that should be cached
     * @param cache_file the path to the JSON cache file for this resolver
     * @param facts the collection of facts to which to add
     */
    void refresh_cache(std::shared_ptr<base_resolver> res, boost::filesystem::path const& cache_file, collection& facts);

    /**
     * Returns the location of the fact cache directory.
     * @return the absolute path to the cache directory
     */
    std::string fact_cache_location();

    /**
     * Returns true if the cache has not expired, false otherwise.
     * @param cache_file the path to the cache file to be verified
     * @param ttl a duration in seconds representing the time to live for the cache
     * @return true if cache is expired, false otherwise
     */
    bool cache_is_valid(boost::filesystem::path const& cache_file, int64_t ttl);

    /**
     * Creates a cache file for the given fact in JSON format.
     * @param file_path the path to the cache file
     * @param fact_name the name of the fact to cache
     */
    void write_json_cache_file(const collection& facts, boost::filesystem::path const& file_path, std::vector<std::string> const& fact_names);

    /**
     * Returns the timespan in seconds since the file was last modified.
     * @param file_path the path to the file
     * @return the timespan in seconds since last modification
     */
    int64_t get_file_lifetime(boost::filesystem::path file_path);

    /**
     * Removes the cache file for any resolver that does not appear in the
     * supplied list of fact groups.
     * @param facts_to_cache the list of fact groups that should be cached
     * @param cache_location the absolute path to the fact cache directory
     */
    void clean_cache(std::unordered_map<std::string, int64_t> const& facts_to_cache,
            std::string cache_location = fact_cache_location());

    /**
     * Caches the custom facts from cached_facts
     * @param collection the collection of facts to which to add
     * @param ttls the duration in seconds for which the cached custom facts file is considered valid
     */
    bool load_cached_custom_facts(collection& collection, int64_t ttl);

    /**
     * Creates a cache file for the given custom facts list in JSON format.
     * @param facts the collection of facts
     * @param cached_custom_facts_list the name of the facts to cache
     */
    void write_cached_custom_facts(const collection& facts, const std::vector<std::string>& cached_custom_facts_list);

}}}  // namespace facter::facts::cache
