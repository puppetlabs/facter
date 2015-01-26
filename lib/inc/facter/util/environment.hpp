/**
* @file
* Declares utility functions for environment variables.
*/
#pragma once

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
         * Note that on Windows, setting an environment variable to an empty string is
         * equivalent to clearing it.
         * @param name The name of the environment variable to set.
         * @param value The value of the environment variable to set.
         * @return Returns true if the environment variable could be changed.
         *         If false, it sets the system error state.
         */
        static bool set(std::string const& name, std::string const& value);

        /**
         * Unsets an environment variable.
         * @param name The name of the environment variable to unset.
         * @return Returns true if the environment variable could be unset.
         *         If false, it sets the system error state.
         */
        static bool clear(std::string const& name);

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

        /**
         * Force search program paths to be reloaded.
         */
        static void reload_search_paths();

        /**
         * Enumerates the environment variables for the current process.
         * @param callback The callback to call for each environment variable (passes the variable name and value).
         */
        static void each(std::function<bool(std::string&, std::string&)> callback);
    };

}}
