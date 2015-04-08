#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
#include <facter/util/scoped_resource.hpp>
#include <leatherman/logging/logging.hpp>

using namespace std;

namespace facter { namespace util { namespace windows { namespace process {

    bool supports_elevated_security()
    {
        // In the future this can use IsWindowsVistaOrGreater, but as of the initial work versionhelpers.h is only in
        // the master branch of MinGW-w64.
        OSVERSIONINFOEXW vi = {sizeof(vi), HIBYTE(_WIN32_WINNT_VISTA), LOBYTE(_WIN32_WINNT_VISTA), 0, 0, {0}, 0};

        return VerifyVersionInfoW(&vi, VER_MAJORVERSION|VER_MINORVERSION|VER_SERVICEPACKMAJOR,
            VerSetConditionMask(VerSetConditionMask(VerSetConditionMask(0,
                VER_MAJORVERSION, VER_GREATER_EQUAL),
                VER_MINORVERSION, VER_GREATER_EQUAL),
                VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL));
    }

    bool has_elevated_security()
    {
        HANDLE temp_token;
        if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &temp_token)) {
            // pre-Vista will return ERROR_NO_SUCH_PRIVILEGE
            if (GetLastError() != ERROR_NO_SUCH_PRIVILEGE) {
                LOG_DEBUG("OpenProcessToken call failed: %1%", system_error());
            }
            return false;
        }
        scoped_resource<HANDLE> token(move(temp_token), CloseHandle);

        TOKEN_ELEVATION token_elevation;
        DWORD token_elevation_length;
        if (!GetTokenInformation(token, TokenElevation, &token_elevation, sizeof(TOKEN_ELEVATION), &token_elevation_length)) {
            LOG_DEBUG("GetTokenInformation call failed: %1%", system_error());
            return false;
        }

        return token_elevation.TokenIsElevated;
    }

}}}}
