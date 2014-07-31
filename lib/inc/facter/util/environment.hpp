#ifndef FACTER_UTIL_ENVIRONMENT_HPP_
#define FACTER_UTIL_ENVIRONMENT_HPP_

#include <string>
#include <vector>

namespace facter { namespace util {

    /**
     * Represents a platform-agnostic way for manipulating environment variables.
     */
    struct environment
    {
        /**
         * Gets an environment variable.
         * @param name The name of the environment variable to get.
         * @param value Returns the value of the environment variable.
         * @return Returns true if the environment variable is present or false if it is not.
         */
        static bool get(std::string const& name, std::string& value);

        /**
         * Sets an environment variable.
         * @param name The name of the environment variable to set.
         * @param value The value of the environment variable to set.
         */
        static void set(std::string const& name, std::string const& value);

        /**
         * Gets the platform-specific path separator.
         * @return Returns the platform-specific path separator.
         */
        static char get_path_separator();

        /**
         * Gets the platform-specific search program paths.
         * @return Returns the platform-specific program search paths.
         */
        static std::vector<std::string> const& search_paths();
    };

}}

#endif  // FACTER_UTIL_ENVIRONMENT_HPP_

