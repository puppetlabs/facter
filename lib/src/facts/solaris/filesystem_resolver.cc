#include <facter/facts/solaris/filesystem_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/scoped_file.hpp>
#include <facter/util/file.hpp>
#include <facter/util/solaris/k_stat.hpp>
#include <facter/util/string.hpp>
#include <facter/execution/execution.hpp>
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
using namespace facter::execution;
using namespace facter::util::solaris;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("facts.solaris.filesystem");

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
            // Skip over anything that doesn't map to a device
            if (!boost::starts_with(entry.mnt_special, "/dev/")) {
                continue;
            }

            mountpoint point;

            struct statvfs stats;
            if (statvfs(entry.mnt_mountp, &stats) != -1) {
                point.size = stats.f_bsize * stats.f_blocks;
                point.available = stats.f_bsize * stats.f_bfree;
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
        re_adapter fs_re("^fs/.*/(.*)$");
        execution::each_line("/usr/sbin/sysdef", [&](string& line) {
            string fs;
            if (re_search(line, fs_re, &fs)) {
                result.filesystems.insert(move(fs));
            }
            return true;
        });
    }

    // TODO: this seems more like a "block device" fact
    // We need a structured fact for that anyway
//    void filesystem_resolver::resolve_partitions(collection& facts)
//    {
//        try {
//            k_stat ks;
//            auto ke = ks["sderr"];
//            auto disk = make_value<map_value>();
//            set<string> disks;
//            for (auto& kv : ke) {
//                auto value = make_value<map_value>();
//                string dname = kv.name();
//                auto pos = dname.find(',');
//                const string name = dname.substr(0, pos);
//
//                string product = kv.value<string>("Product");
//                string vendor = kv.value<string>("Vendor");
//                string size = si_string(kv.value<uint64_t>("Size"));
//                value->add("product", make_value<string_value>(move(product)));
//                value->add("vendor", make_value<string_value>(move(vendor)));
//                value->add("size", make_value<string_value>(move(size)));
//                disk->add(name.c_str(), move(value));
//                disks.insert(name);
//            }
//            facts.add(fact::disks, make_value<string_value>(boost::join(disks, ",")));
//            facts.add(fact::disk, move(disk));
//        } catch (kstat_exception& ex) {
//            LOG_DEBUG("partition resolver failed (%1%)", ex.what());
//        }
//    }

}}}  // namespace facter::facts::solaris
