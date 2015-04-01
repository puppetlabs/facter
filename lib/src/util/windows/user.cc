#include <internal/util/windows/user.hpp>
#include <internal/util/windows/process.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
#include <facter/util/environment.hpp>
#include <leatherman/logging/logging.hpp>

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
        string home, alt;
        if (environment::get("HOME", home)) {
            return home;
        } else if (environment::get("HOMEDRIVE", home) && environment::get("HOMEPATH", alt)) {
            return home + alt;
        } else if (environment::get("USERPROFILE", home)) {
            return home;
        }
        return {};
    }

}}}}
