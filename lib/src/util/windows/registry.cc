#include <facter/util/windows/registry.hpp>
#include <facter/util/windows/system_error.hpp>
#include <boost/format.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <boost/nowide/convert.hpp>
#include <facter/util/windows/windows.hpp>

using namespace std;

namespace facter { namespace util { namespace windows {

    registry_exception::registry_exception(string const& message) :
        runtime_error(message)
    {
    }

    static HKEY get_hkey(registry::HKEY hkey)
    {
        switch (hkey) {
            case registry::HKEY::CLASSES_ROOT:        return HKEY_CLASSES_ROOT;
            case registry::HKEY::CURRENT_CONFIG:      return HKEY_CURRENT_CONFIG;
            case registry::HKEY::CURRENT_USER:        return HKEY_CURRENT_USER;
            case registry::HKEY::LOCAL_MACHINE:       return HKEY_LOCAL_MACHINE;
            case registry::HKEY::PERFORMANCE_DATA:    return HKEY_PERFORMANCE_DATA;
            case registry::HKEY::PERFORMANCE_NLSTEXT: return HKEY_PERFORMANCE_NLSTEXT;
            case registry::HKEY::PERFORMANCE_TEXT:    return HKEY_PERFORMANCE_TEXT;
            case registry::HKEY::USERS:               return HKEY_USERS;
            default:
                throw registry_exception("invalid HKEY specified");
        }
    }

    // Returns the registry value as a wstring buffer. It's up to the caller to interpret it.
    // This only really works for RRF_RT_REG_EXPAND_SZ, RRF_RT_REG_MULTI_SZ, and RRF_RT_REG_SZ.
    static wstring get_regvalue(registry::HKEY hkey, string const& lpSubKey, string const& lpValue, DWORD flags)
    {
        auto hk = get_hkey(hkey);
        auto lpSubKeyW = boost::nowide::widen(lpSubKey);
        auto lpValueW = boost::nowide::widen(lpValue);

        DWORD size = 0u;
        auto err = RegGetValueW(hk, lpSubKeyW.c_str(), lpValueW.c_str(), flags, nullptr, nullptr, &size);
        if (err != ERROR_SUCCESS) {
            throw registry_exception(str(boost::format("error reading registry key %1% %2%: %3%") %
                lpSubKey % lpValue % system_error(err)));
        }

        // Size is the number of bytes needed.
        wstring buffer((size*sizeof(char))/sizeof(wchar_t), '\0');
        err = RegGetValueW(hk, lpSubKeyW.c_str(), lpValueW.c_str(), flags, nullptr, &buffer[0], &size);
        if (err != ERROR_SUCCESS) {
            throw registry_exception(str(boost::format("error reading registry key %1% %2%: %3%") %
                lpSubKey % lpValue % system_error(err)));
        }

        // Size now represents bytes copied (which can be less than we allocated). Resize, and also remove the
        // extraneous null-terminator from RegGetValueW (wstring handles termination internally).
        auto numwchars = (size*sizeof(char))/sizeof(wchar_t);
        buffer.resize(numwchars > 0u ? numwchars - 1u : 0u);

        return buffer;
    }

    string registry::get_registry_string(registry::HKEY hkey, string const& subkey, string const& value)
    {
        // From http://msdn.microsoft.com/en-us/library/windows/desktop/ms724868(v=vs.85).aspx
        // "RRF_RT_REG_SZV automatically converts REG_EXPAND_SZ to REG_SZ unless RRF_NOEXPAND is specified."
        // This seems like the desired behavior most of the time.
        return boost::nowide::narrow(get_regvalue(hkey, subkey, value, RRF_RT_REG_SZ));
    }

    vector<string> registry::get_registry_strings(registry::HKEY hkey, string const& subkey, string const& value)
    {
        auto buffer = get_regvalue(hkey, subkey, value, RRF_RT_REG_MULTI_SZ);

        vector<string> strings;

        wstring accum;
        for (auto c : buffer) {
            if (c == L'\0') {
                string val = boost::trim_copy(boost::nowide::narrow(accum));
                if (!val.empty()) {
                    strings.emplace_back(move(val));
                }
                accum.clear();
            } else {
                accum += c;
            }
        }
        return strings;
    }

}}}  // namespace facter::util::windows
