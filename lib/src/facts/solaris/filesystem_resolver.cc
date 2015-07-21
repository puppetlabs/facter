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
#include <set>
#include <map>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::util::solaris;
using namespace leatherman::util;
using namespace boost::filesystem;

using execution = leatherman::execution;

namespace facter { namespace facts { namespace solaris {

    filesystem_resolver::data filesystem_resolver::collect_data(collection& facts)
    {
        data result;
        collect_mountpoint_data(result);
        collect_filesystem_data(result);
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
        while (getmntent(file, &entry) == 0) {
            mountpoint point;

            struct statvfs64 stats;
            if (statvfs64(entry.mnt_mountp, &stats) != -1) {
                point.size = stats.f_frsize * stats.f_blocks;
                point.available = stats.f_frsize * stats.f_bfree;
            }

            point.name = entry.mnt_mountp;
            point.device = entry.mnt_special;
            point.filesystem = entry.mnt_fstype;
            boost::split(point.options, entry.mnt_mntopts, boost::is_any_of(","), boost::token_compress_on);

            result.mountpoints.emplace_back(move(point));
        }
    }

    void filesystem_resolver::collect_filesystem_data(data& result)
    {
        // Build a list of mounted filesystems
        static boost::regex fs_re("^fs/.*/(.*)$");
        each_line("/usr/sbin/sysdef", [&](string& line) {
            string fs;
            if (re_search(line, fs_re, &fs)) {
                result.filesystems.insert(move(fs));
            }
            return true;
        });
    }

}}}  // namespace facter::facts::solaris
