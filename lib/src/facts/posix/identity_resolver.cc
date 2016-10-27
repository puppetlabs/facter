#include <internal/facts/posix/identity_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/types.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>

using namespace std;

namespace facter { namespace facts { namespace posix {

    identity_resolver::data identity_resolver::collect_data(collection& facts)
    {
        data result;

        vector<char> buffer;
        long buffer_size = sysconf(_SC_GETPW_R_SIZE_MAX);

        if (buffer_size == -1) {
            buffer.resize(1024);
        } else {
            buffer.resize(buffer_size);
        }

        uid_t uid = geteuid();
        struct passwd pwd;
        struct passwd *pwd_ptr;
        int err = getpwuid_r(uid, &pwd, buffer.data(), buffer.size(), &pwd_ptr);

        if (err != 0) {
            LOG_WARNING("getpwuid_r failed: {1} ({2})", strerror(err), err);
        } else if (pwd_ptr == NULL) {
            LOG_WARNING("effective uid {1} does not have a passwd entry.", uid);
        } else {
            result.user_id = static_cast<int64_t>(uid);
            result.user_name = pwd.pw_name;
            result.privileged = (uid == 0);
        }

        buffer_size = sysconf(_SC_GETGR_R_SIZE_MAX);

        if (buffer_size == -1) {
            buffer.resize(1024);
        } else {
            buffer.resize(buffer_size);
        }

        gid_t gid = getegid();
        struct group grp;
        struct group *grp_ptr;
        err = getgrgid_r(gid, &grp, buffer.data(), buffer.size(), &grp_ptr);

        if (err != 0) {
            LOG_WARNING("getgrgid_r failed: {1} ({2})", strerror(err), err);
        } else if (grp_ptr == NULL) {
            LOG_WARNING("effective gid {1} does not have a group entry.", gid);
        } else {
            result.group_id = static_cast<int64_t>(gid);
            result.group_name = grp.gr_name;
        }

        return result;
    }

}}}  // facter::facts::posix
