/**
 * @file
 * Declares methods for interacting with Facter's config file.
 */
#pragma once

#include "../export.h"
#include <hocon/config.hpp>
#include <boost/program_options.hpp>

namespace facter { namespace util { namespace config {
    /**
     * Parses the contents of Facter's config file from its default location
     * for the current operating system.
     * @return HOCON config object, or nullptr if no file was found
     */
    LIBFACTER_EXPORT hocon::shared_config load_default_config_file();

    /**
     * Returns the default location of the config file.
     * @return the absolute path to the default config file
     */
    LIBFACTER_EXPORT std::string default_config_location();

    /**
     * Parses the contents of the config pile at the specified path.
     * @param config_path the path to the config file
     * @return HOCON config object, or nullptr if no file was found
     */
    LIBFACTER_EXPORT hocon::shared_config load_config_from(std::string config_path);

    /**
     * Loads the "global" section of the config file into the settings map.
     * @param hocon_config the config object representing the parsed config file
     * @param vm the key-value map in which to store the settings
     */
    LIBFACTER_EXPORT void load_global_settings(hocon::shared_config hocon_config, boost::program_options::variables_map& vm);

    /**
     * Loads the "cli" section of the config file into the settings map.
     * @param hocon_config the config object representing the parsed config file
     * @param vm the key-value map in which to store the settings
     */
    LIBFACTER_EXPORT void load_cli_settings(hocon::shared_config hocon_config, boost::program_options::variables_map& vm);

    /**
     * Loads the "blocklist" section of the config file into the settings map.
     * @param hocon_config the config object representing the parsed config file
     * @param vm the key-value map in which to store the settings
     */
    LIBFACTER_EXPORT void load_fact_settings(hocon::shared_config hocon_config, boost::program_options::variables_map& vm);

    /**
     * Returns a schema of the valid global options that can appear in the config file.
     * @return names, values, and descriptions of global Facter options
     */
    LIBFACTER_EXPORT boost::program_options::options_description global_config_options();

    /**
     * Returns a schema of the valid config file options affecting Facter's command line interface.
     * @return names, values, and descriptions of command line options
     */
    LIBFACTER_EXPORT boost::program_options::options_description cli_config_options();

    /**
     * Returns a schema for options dealing with block fact collection.
     * @return names, values, and descriptions of fact blocking config options
     */
    LIBFACTER_EXPORT boost::program_options::options_description fact_config_options();

    /**
     * Returns a map of resolver names and durations (in milliseconds). The listed resolvers will
     * have their output cached, then re-resolved no more frequently than the given interval.
     * @param hocon_config the config object representing the parsed config file
     * @return a map of resolvers to time-to-live durations (in milliseconds)
     */
    LIBFACTER_EXPORT std::unordered_map<std::string, int64_t> load_ttls(hocon::shared_config hocon_config);

    /**
     * Returns the directory of the fact cache.
     * @return the absolute path to the fact cache
     */
    LIBFACTER_EXPORT std::string fact_cache_location();
}}}  // namespace facter::util::config
