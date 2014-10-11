#pragma once

#include <string>
#include <map>
#include <vector>
#include <boost/algorithm/string.hpp>

namespace facter { namespace util { namespace windows { namespace wmi {

    /**
     * Identifier for the WMI class Win32_ComputerSystem
     */
    constexpr static char const* computersystem = "Win32_ComputerSystem";

    /**
     * Identifier for the WMI class Win32_ComputerSystemProduct
     */
    constexpr static char const* computersystemproduct = "Win32_ComputerSystemProduct";

    /**
     * Identifier for the WMI class Win32_BIOS
     */
    constexpr static char const* bios = "Win32_Bios";

    /**
     * Identifier fot the WMI property Name
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
     * Case-insensitive string comparison.
     */
    struct ciless : std::binary_function<std::string, std::string, bool>
    {
        bool operator() (const std::string &s1, const std::string &s2) const {
            return boost::lexicographical_compare(s1, s2, boost::is_iless());
        }
    };

    /**
     * Map with case-insensitive lookup.
     */
    using imap = std::map<std::string, std::string, ciless>;

    /**
     * This is a utility for querying WMI classes. Windows queries are case-insensitive,
     * so the returned keys aren't guaranteed to have the same case as the arguments.
     * Returns a case-insensitive map so the argument keys can safely be used for lookup.
     * @param group The class alias to query
     * @param keys A list of keys to query from the specified class
     * @return A case-insensitive map of the keys argument and their corresponding values
     */
    imap query(std::string const& group, std::vector<std::string> const& keys);

    /**
     * Releases COM resources acquired on the first call to query.
     */
    void release();

}}}}  // namespace facter::util::windows::wmi
