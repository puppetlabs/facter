/**
 * @file
 * Declares utility functions for interacting with the Windows registry.
 */
#pragma once

#include <string>
#include <vector>
#include <stdexcept>

namespace facter { namespace util { namespace windows {

    /**
     * Exception thrown when registry lookupfails.
     */
    struct registry_exception : std::runtime_error
    {
        /**
         * Constructs a registry_exception.
         * @param message The exception message.
         */
        explicit registry_exception(std::string const& message);
    };

    namespace registry {
        /**
         * HKEY Classes, derived from
         * http://msdn.microsoft.com/en-us/library/windows/desktop/ms724868(v=vs.85).aspxs
         */
        enum class HKEY {
            CLASSES_ROOT, CURRENT_CONFIG, CURRENT_USER, LOCAL_MACHINE,
            PERFORMANCE_DATA, PERFORMANCE_NLSTEXT, PERFORMANCE_TEXT, USERS
        };

        /**
         * Retrieve a string value from the registry.
         * @param hkey The registry key handle.
         * @param subkey The name of the registry key.
         * @param value The name of the registry value.
         * @return A string value corresponding to a REG_SZ or REG_EXPAND_SZ type.
         *         Returns an empty string if the value doesn't exist or isn't a string type.
         */
        std::string get_registry_string(HKEY hkey, std::string const& subkey, std::string const& value);

        /**
         * Retrieve a vector of string values from the registry.
         * @param hkey The registry key handle.
         * @param subkey The name of the registry key.
         * @param value The name of the registry value.
         * @return An array of string values corresponding to the REG_MULTI_SZ type.
         *         Returns an empty vector if the value doesn't exist or isn't a composite string type.
         */
        std::vector<std::string> get_registry_strings(HKEY hkey, std::string const& subkey, std::string const& value);
    }

}}}  // facter::util::windows
