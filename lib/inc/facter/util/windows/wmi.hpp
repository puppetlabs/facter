#pragma once

#include <facter/util/scoped_resource.hpp>
#include <string>
#include <map>
#include <vector>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/algorithm/string/compare.hpp>

// Forward declarations
class IWbemLocator;
class IWbemServices;

namespace facter { namespace util { namespace windows {

    /**
     * Exception thrown when wmi initialization fails.
     */
    struct wmi_exception : std::runtime_error
    {
        /**
         * Constructs a wmi_exception.
         * @param message The exception message.
         */
        explicit wmi_exception(std::string const& message);
    };

    /**
     * A class for initiating a WMI connection over COM and querying it.
     */
    struct wmi {
        /**
         * Identifier for the WMI class Win32_ComputerSystem
         */
        constexpr static char const* computersystem = "Win32_ComputerSystem";

        /**
         * Identifier for the WMI class Win32_ComputerSystemProduct
         */
        constexpr static char const* computersystemproduct = "Win32_ComputerSystemProduct";

        /**
         * Identifier for the WMI class Win32_OperatingSystem
         */
        constexpr static char const* operatingsystem = "Win32_OperatingSystem";

        /**
         * Identifier for the WMI class Win32_BIOS
         */
        constexpr static char const* bios = "Win32_Bios";

        /**
         * Identifier for the WMI class Win32_Processor
         */
        constexpr static char const* processor = "Win32_Processor";

        /**
         * Identifier for the WMI property Name
         */
        constexpr static char const* name = "Name";

        /**
         * Identifier for the WMI property Manufacturer
         */
        constexpr static char const* manufacturer = "Manufacturer";

        /**
         * Identifier for the WMI property Model
         */
        constexpr static char const* model = "Model";

        /**
         * Identifier for the WMI property SerialNumber
         */
        constexpr static char const* serialnumber = "SerialNumber";

        /**
         * Identifier for the WMI property NumberOfLogicalProcessors
         */
        constexpr static char const* numberoflogicalprocessors = "NumberOfLogicalProcessors";

        /**
         * Identifier for the WMI property LastBootUpTime
         */
        constexpr static char const* lastbootuptime = "LastBootUpTime";

        /**
         * Identifier for the WMI property LocalDateTime
         */
        constexpr static char const* localdatetime = "LocalDateTime";

        /**
         * Identifier for the WMI property ProductType
         */
        constexpr static char const* producttype = "ProductType";

        /**
         * Identifier for the WMI property OtherTypeDescription
         */
        constexpr static char const* othertypedescription = "OtherTypeDescription";

        /**
         * Case-insensitive string comparison.
         */
        struct ciless : std::binary_function<std::string, std::string, bool>
        {
            /**
             * Compares two strings for a "less than" relationship using a case-insensitive comparison.
             * @param s1 The first string to compare.
             * @param s2 The second string to compare.
             * @return Returns true if s1 is less than s2 or false if s1 is equal to or greater than s2.
             */
            bool operator() (const std::string &s1, const std::string &s2) const {
                return boost::lexicographical_compare(s1, s2, boost::is_iless());
            }
        };

        /**
         * Multi-map with case-insensitive lookup.
         */
        using imap = std::multimap<std::string, std::string, ciless>;

        /**
         * Initializes a COM connection for WMI queries. Throws a wmi_exception on failure.
         */
        wmi();

        /**
         * This is a utility for querying WMI classes. Windows queries are case-insensitive,
         * so the returned keys aren't guaranteed to have the same case as the arguments.
         * Returns a case-insensitive map so the argument keys can safely be used for lookup.
         * Some groups can return multiple objects; in that case the returned multimap will
         * have multiple entries for each key.
         * @param group The class alias to query
         * @param keys A list of keys to query from the specified class
         * @return A case-insensitive map of the keys argument and their corresponding values
         */
        imap query(std::string const& group, std::vector<std::string> const& keys) const;

        /**
         * A utility for retrieving a single entry from an imap. It should only be used if
         * it's known that the requested group will only return a single object.
         * To retrieve multiple values, use imap's equal_range.
         * @param kvmap A case-insensitive multimap of keys and their values.
         * @param key The key to lookup.
         * @return Return the value matching the specified key.
         */
        static std::string const& get(imap const& kvmap, std::string const& key);

     private:
        scoped_resource<bool> _coInit;
        scoped_resource<IWbemLocator *> _pLoc;
        scoped_resource<IWbemServices *> _pSvc;
    };

}}}  // namespace facter::util::windows
