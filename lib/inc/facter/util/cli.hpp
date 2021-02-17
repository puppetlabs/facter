/**
 * @file
 * Declares methods for interacting with Facter's CLI options.
 */
#pragma once

#include "../export.h"
#include <hocon/config.hpp>
#include <boost/program_options.hpp>

namespace facter { namespace util { namespace cli {
    /**
     * Checks for conflicting CLI options and throws an error if one is found
     * @param vm the key-value map with settings
     */
    LIBFACTER_EXPORT void validate_cli_options(boost::program_options::variables_map vm);

    /**
     * Returns a schema for visible CLI options
     * @return names, values, and descriptions of visible CLI options
     */
    LIBFACTER_EXPORT boost::program_options::options_description get_visible_options();

    /**
     * Parses the passed in command line arguments and stores them into a key-value map
     * @param vm the key-value map in which to store the settings
     * @param visible_options names, values and description of visible CLI options
     * @param argc the number of command line options
     * @param argv an array of command line arguments 
     */
    LIBFACTER_EXPORT void load_cli_options(boost::program_options::variables_map& vm, boost::program_options::options_description& visible_options, int argc, char** argv);

    /**
     * Returns a set of sanitized CLI queries
     * @param query an array of queries
     * @return a set of parsed queries
     */
    LIBFACTER_EXPORT std::set<std::string> sanitize_cli_queries(std::vector<std::string> query);
}}}  // namespace facter::util::cli
