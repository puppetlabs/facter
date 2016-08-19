#include <facter/facts/fact.hpp>
#include <internal/facts/solaris/filesystem_resolver.hpp>
#include <internal/util/solaris/k_stat.hpp>
#include <internal/util/scoped_file.hpp>
#include <leatherman/file_util/file.hpp>
#include <facter/util/string.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <sys/mnttab.h>
#include <fcntl.h>
#include <sys/vfs.h>
#include <sys/statvfs.h>
#include <unordered_set>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::util::solaris;
using namespace leatherman::util;
using namespace boost::filesystem;

namespace facter { namespace facts { namespace solaris {

    filesystem_resolver::data filesystem_resolver::collect_data(collection& facts, set<string> const& blocklist)
    {
        data result;

        if (blocklist.count(fact::mountpoints)) {
            log_fact_blockage(fact::mountpoints);
        } else {
            collect_mountpoint_data(result);
        }

        if (blocklist.count(fact::filesystems)) {
            log_fact_blockage(fact::mountpoints);
        } else {
            collect_filesystem_data(result);
        }
        return result;
    }

    void filesystem_resolver::collect_mountpoint_data(data& result)
    {
        scoped_file file(fopen("/etc/mnttab", "r"));
        if (!static_cast<FILE*>(file)) {
            LOG_ERROR("fopen of /etc/mnttab failed: %1% (%2%): mountpoint data is unavailable.", strerror(errno), errno);
            return;
        }

        mnttab entry;
        unordered_set<string> auto_home_paths;
        vector<mountpoint> mountpoints;
        while (getmntent(file, &entry) == 0) {
            mountpoint point;

            struct statvfs64 stats;
            if (statvfs64(entry.mnt_mountp, &stats) != -1) {
                point.size = stats.f_frsize * stats.f_blocks;
                point.available = stats.f_frsize * stats.f_bfree;
            }

            if (entry.mnt_special == string("auto_home")) {
                auto_home_paths.emplace(entry.mnt_mountp);
                continue;
            } else if (entry.mnt_fstype == string("autofs")) {
                continue;
            }

            point.name = entry.mnt_mountp;
            point.device = entry.mnt_special;
            point.filesystem = entry.mnt_fstype;
            boost::split(point.options, entry.mnt_mntopts, boost::is_any_of(","), boost::token_compress_on);

            mountpoints.emplace_back(move(point));
        }

        for (auto& point : mountpoints) {
            auto mount_parent = point.name.substr(0, point.name.find_last_of('/'));

            // Only add entries that are not mounted from an auto_home setup
            if (auto_home_paths.count(mount_parent) == 0) {
                result.mountpoints.emplace_back(move(point));
            }
        }
    }

    void filesystem_resolver::collect_filesystem_data(data& result)
    {
        // Build a list of mounted filesystems
        static boost::regex fs_re("^fs/.*/(.*)$");
        leatherman::execution::each_line("/usr/sbin/sysdef", [&](string& line) {
            string fs;
            if (re_search(line, fs_re, &fs)) {
                result.filesystems.insert(move(fs));
            }
            return true;
        });
    }

}}}  // namespace facter::facts::solaris
