#include <internal/facts/windows/identity_resolver.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/user.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/nowide/convert.hpp>
#include <security.h>

using namespace std;
using namespace leatherman::windows;

namespace facter { namespace facts { namespace windows {

    identity_resolver::data identity_resolver::collect_data(collection& facts)
    {
        data result;

        // Groups are a lot more flexible on Windows than Linux. We only support
        // identifying the user right now.
        ULONG size = 0ul;
        auto nameformat = NameSamCompatible;
        GetUserNameExW(nameformat, nullptr, &size);
        if (GetLastError() != ERROR_MORE_DATA) {
            LOG_DEBUG("failure resolving identity facts: %1%", leatherman::windows::system_error());
            return result;
        }

        // Use the string as a raw buffer that supports move and ref operations.
        wstring buffer(size, '\0');
        if (!GetUserNameExW(nameformat, &buffer[0], &size)) {
            LOG_DEBUG("failure resolving identity facts: %1%", leatherman::windows::system_error());
            return result;
        }

        // Resize the buffer to the returned string size.
        buffer.resize(size);
        result.user_name = boost::nowide::narrow(buffer);

        // Check whether this thread is running with elevated privileges
        // (or with the privileges of the local Administrators group on
        // older versions of Windows not supporting privileges elevation).
        result.privileged = user::is_admin();

        return result;
    }
}}}  // facter::facts::windows
