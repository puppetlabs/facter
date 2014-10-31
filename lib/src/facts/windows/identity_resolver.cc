#include <facter/facts/windows/identity_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <facter/util/windows/string_conv.hpp>
#define SECURITY_WIN32
#include <security.h>

#undef LOG_NAMESPACE
#define LOG_NAMESPACE "facts.windows.identity"

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
            auto err = GetLastError();
            LOG_DEBUG("failure resolving identity facts: %1% (%2%)", scoped_error(err), err);
            return result;
        }

        // Use the string as a raw buffer that supports move and ref operations.
        wstring buffer(size, '\0');
        if (!GetUserNameExW(nameformat, &buffer[0], &size)) {
            auto err = GetLastError();
            LOG_DEBUG("failure resolving identity facts: %1% (%2%)", scoped_error(err), err);
            return result;
        }

        // Resize the buffer to the returned string size.
        buffer.resize(size);
        result.user_name = to_utf8(buffer);
        return result;
    }
}}}  // facter::facts::windows
