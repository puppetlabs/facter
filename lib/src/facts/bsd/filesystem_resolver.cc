#include <facter/facts/fact.hpp>
#include <internal/facts/bsd/filesystem_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <sys/mount.h>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

namespace facter { namespace facts { namespace bsd {

    filesystem_resolver::data filesystem_resolver::collect_data(collection& facts, set<string> const& blocklist)
    {
        data result;

        if (blocklist.count(fact::mountpoints) || blocklist.count(fact::filesystems)) {
            // since these both come from the same data collection path, blocking one blocks the other
            log_fact_blockage(fact::mountpoints);
            log_fact_blockage(fact::filesystems);
            return result;
        }

        // First get the count of file systems
        int count = getfsstat(nullptr, 0, MNT_NOWAIT);
        if (count == -1) {
            LOG_ERROR("getfsstat failed: %1% (%2%): file system facts are unavailable.", strerror(errno), errno);
            return result;
        }

        // Get the actual data
        vector<struct statfs> filesystems(count);
        count = getfsstat(filesystems.data(), filesystems.size() * sizeof(struct statfs), MNT_NOWAIT);
        if (count == -1) {
            LOG_ERROR("getfsstat failed: %1% (%2%): file system facts are unavailable.", strerror(errno), errno);
            return result;
        }

        result.mountpoints.reserve(count);

        // Populate an entry for each mounted file system
        for (auto& fs : filesystems) {
            mountpoint point;
            point.name = fs.f_mntonname;
            point.device = fs.f_mntfromname;
            point.filesystem = fs.f_fstypename;
            point.size = (static_cast<uint64_t>(fs.f_bsize)
                          * static_cast<uint64_t>(fs.f_blocks));
            point.available = (static_cast<uint64_t>(fs.f_bsize)
                               * static_cast<uint64_t>(fs.f_bfree));
            point.options = to_options(fs);
            result.mountpoints.emplace_back(move(point));

            result.filesystems.insert(fs.f_fstypename);
        }
        return result;
    }

    vector<string> filesystem_resolver::to_options(struct statfs const& fs)
    {
        static vector<tuple<unsigned int, string>> const flags = {
            make_tuple<unsigned int, string>(MNT_RDONLY,       "readonly"),
            make_tuple<unsigned int, string>(MNT_SYNCHRONOUS,  "noasync"),
            make_tuple<unsigned int, string>(MNT_NOEXEC,       "noexec"),
            make_tuple<unsigned int, string>(MNT_NOSUID,       "nosuid"),
#ifndef __OpenBSD__
            make_tuple<unsigned int, string>(MNT_UNION,        "union"),
#endif
            make_tuple<unsigned int, string>(MNT_ASYNC,        "async"),
            make_tuple<unsigned int, string>(MNT_EXPORTED,     "exported"),
            make_tuple<unsigned int, string>(MNT_LOCAL,        "local"),
            make_tuple<unsigned int, string>(MNT_QUOTA,        "quota"),
            make_tuple<unsigned int, string>(MNT_ROOTFS,       "root"),
            make_tuple<unsigned int, string>(MNT_NOATIME,      "noatime"),
#if !defined(__FreeBSD__)
            make_tuple<unsigned int, string>(MNT_NODEV,        "nodev"),
#endif
#if !defined(__FreeBSD__) && !defined(__OpenBSD__)
            // the following constants aren't defined on FreeBSD 10/OpenBSD
            make_tuple<unsigned int, string>(MNT_DONTBROWSE,   "nobrowse"),
            make_tuple<unsigned int, string>(MNT_AUTOMOUNTED,  "automounted"),
            make_tuple<unsigned int, string>(MNT_JOURNALED,    "journaled"),
            make_tuple<unsigned int, string>(MNT_DEFWRITE,     "deferwrites"),
#endif
#ifdef __OpenBSD__
            make_tuple<unsigned int, string>(MNT_WXALLOWED,     "wxallowed"),
#endif
        };

        vector<string> options;
        for (auto const& flag : flags) {
            if (fs.f_flags & get<0>(flag)) {
                options.push_back(get<1>(flag));
            }
        }
        return options;
    }

}}}  // namespace facter::facts::bsd
