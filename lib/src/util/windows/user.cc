#include <internal/util/windows/user.hpp>
#include <internal/util/windows/process.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
#include <facter/util/scoped_resource.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/nowide/convert.hpp>
#include <userenv.h>

using namespace std;

namespace facter { namespace util { namespace windows { namespace user {

    bool is_admin()
    {
        if (process::supports_elevated_security()) {
            return process::has_elevated_security();
        }

        return check_token_membership();
    }

    bool check_token_membership()
    {
        DWORD sid_size = SECURITY_MAX_SID_SIZE;
        unsigned char sid_buffer[SECURITY_MAX_SID_SIZE];
        auto sid = static_cast<PSID>(&sid_buffer);
        if (!CreateWellKnownSid(WinBuiltinAdministratorsSid, nullptr, sid, &sid_size)) {
            LOG_DEBUG("Failed to create administrators SID: %1%", system_error());
            return false;
        }

        if (!IsValidSid(sid)) {
            LOG_DEBUG("Invalid SID");
            return false;
        }

        BOOL is_member;
        if (!CheckTokenMembership(nullptr, sid, &is_member)) {
            LOG_DEBUG("Failed to check membership: %1%", system_error());
            return false;
        }

        return is_member;
    }

    string home_dir()
    {
        HANDLE temp_token = INVALID_HANDLE_VALUE;
        if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &temp_token)) {
            LOG_DEBUG("OpenProcessToken call failed: %1%", system_error());
            return {};
        }
        scoped_resource<HANDLE> token(temp_token, CloseHandle);

        DWORD pathLen = 0u;
        if (GetUserProfileDirectoryW(token, nullptr, &pathLen)) {
            LOG_DEBUG("GetUserProfileDirectoryW call returned unexpectedly");
            return {};
        } else if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
            LOG_DEBUG("GetUserProfileDirectoryW call failed: %1%", system_error());
            return {};
        }

        wstring buffer(pathLen, '\0');
        if (!GetUserProfileDirectoryW(token, &buffer[0], &pathLen)) {
            LOG_DEBUG("GetUserProfileDirectoryW call failed: %1%", system_error());
            return {};
        }

        // Strip the trailing null character.
        buffer.resize(pathLen > 0u ? pathLen - 1u : 0u);
        return boost::nowide::narrow(buffer);
    }

}}}}
