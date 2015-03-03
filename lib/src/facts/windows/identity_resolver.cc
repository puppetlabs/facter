#include <facter/facts/windows/identity_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/util/windows/system_error.hpp>
#include <boost/nowide/convert.hpp>

#include <facter/util/windows/windows.hpp>
#include <security.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;

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
            LOG_DEBUG("failure resolving identity facts: %1% (%2%)", system_error());
            return result;
        }

        // Use the string as a raw buffer that supports move and ref operations.
        wstring buffer(size, '\0');
        if (!GetUserNameExW(nameformat, &buffer[0], &size)) {
            LOG_DEBUG("failure resolving identity facts: %1% (%2%)", system_error());
            return result;
        }

        // Resize the buffer to the returned string size.
        buffer.resize(size);
        result.user_name = boost::nowide::narrow(buffer);
        return result;
    }
}}}  // facter::facts::windows
