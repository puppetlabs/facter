#include <facter/facts/posix/id_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <sys/types.h>
#include <pwd.h>
#include <grp.h>

LOG_DECLARE_NAMESPACE("facts.posix.id");

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace posix {

    id_resolver::id_resolver() :
        resolver(
            "id",
            {
                fact::id,
                fact::gid,
            })
    {
    }

    void id_resolver::resolve_facts(collection &facts)
    {
        resolve_id(facts);
        resolve_gid(facts);
    }

    void id_resolver::resolve_id(collection &facts)
    {
        long initlen = sysconf(_SC_GETPW_R_SIZE_MAX);
        size_t buflen;

        if (initlen == -1) {
            buflen = 1024;
        } else {
            buflen = initlen;
        }

        uid_t uid = geteuid();
        std::vector<char> buf(buflen);
        struct passwd pwd;
        struct passwd *pwd_ptr;
        int err = getpwuid_r(uid, &pwd, buf.data(), buf.size(), &pwd_ptr);

        if (err != 0) {
            LOG_WARNING("getpwuid_r failed: %1% (%2%)", strerror(err), err);
        } else if (pwd_ptr == NULL) {
            LOG_WARNING("effective uid %1% does not have a passwd entry.", uid);
        } else {
            facts.add(fact::id, make_value<string_value>(pwd.pw_name));
        }
    }

    void id_resolver::resolve_gid(collection &facts)
    {
        long initlen = sysconf(_SC_GETGR_R_SIZE_MAX);
        size_t buflen;

        if (initlen == -1) {
            buflen = 1024;
        } else {
            buflen = initlen;
        }

        gid_t gid = getegid();
        std::vector<char> buf(buflen);
        struct group grp;
        struct group *grp_ptr;
        int err = getgrgid_r(gid, &grp, buf.data(), buf.size(), &grp_ptr);

        if (err != 0) {
            LOG_WARNING("getgrgid_r failed: %1% (%2%)", strerror(err), err);
        } else if (grp_ptr == NULL) {
            LOG_WARNING("effective gid %1% does not have a group entry.", gid);
        } else {
            facts.add(fact::gid, make_value<string_value>(grp.gr_name));
        }
    }
}}}  // facter::facts::posix
