#include <facter/facts/solaris/filesystem_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
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

    void filesystem_resolver::resolve_mountpoints(collection& facts)
    {
        scoped_file file(fopen("/etc/mnttab", "r"));
        if (!static_cast<FILE*>(file)) {
            LOG_ERROR("fopen of /etc/mnttab failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::mountpoints);
            return;
        }

        auto mountpoints = make_value<map_value>();

        mnttab entry;
        while (getmntent(file, &entry) == 0) {
            // Skip over anything that doesn't map to a device
            if (!boost::starts_with(entry.mnt_special, "/dev/")) {
                continue;
            }

            uint64_t size = 0;
            uint64_t available = 0;
            struct statvfs stats;
            if (statvfs(entry.mnt_mountp, &stats) != -1) {
                size = stats.f_bsize * stats.f_blocks;
                available = stats.f_bsize * stats.f_bfree;
            }

            uint64_t used = size - available;

            auto value = make_value<map_value>();
            value->add("size_bytes", make_value<integer_value>(size));
            value->add("size", make_value<string_value>(si_string(size)));
            value->add("available_bytes", make_value<integer_value>(available));
            value->add("available", make_value<string_value>(si_string(available)));
            value->add("used_bytes", make_value<integer_value>(used));
            value->add("used", make_value<string_value>(si_string(used)));
            value->add("capacity", make_value<string_value>(percentage(used, size)));
            value->add("filesystem", make_value<string_value>(entry.mnt_fstype));
            value->add("device", make_value<string_value>(entry.mnt_special));

            // Split the options based on ','
            auto options = make_value<array_value>();
            vector<string> mount_options;
            boost::split(mount_options, entry.mnt_mntopts, boost::is_any_of(","), boost::token_compress_on);
            for (auto& option : mount_options) {
                options->add(make_value<string_value>(move(option)));
            }
            value->add("options", move(options));

            mountpoints->add(entry.mnt_mountp, move(value));
        }

        if (mountpoints->size() > 0) {
            facts.add(fact::mountpoints, move(mountpoints));
        }
    }

    void filesystem_resolver::resolve_filesystems(collection& facts)
    {
        auto mountpoints = facts.get<map_value>(fact::mountpoints, false);
        if (!mountpoints) {
            return;
        }

        // Build a list of mounted filesystems

        set<string> filesystems;
        re_adapter fs_re("^fs/.*/(.*)$");
        string fs;
        execution::each_line("/usr/sbin/sysdef", [&] (string& line) {
            if (re_search(line, fs_re, &fs)) {
                filesystems.insert(fs);
            }
            return true;
        });

        if (filesystems.size() == 0) {
            return;
        }

        facts.add(fact::filesystems, make_value<string_value>(boost::join(filesystems, ",")));
    }

    void filesystem_resolver::resolve_partitions(collection& facts)
    {
        try {
            k_stat ks;
            multimap<string, string> partmap;
            auto ke = ks["sd"];
            for (auto& kv : ke) {
                string klass = kv.klass();
                if (klass != "partition") {
                    continue;
                }
                string val = kv.name();
                auto pos = val.find(',');
                if (pos != val.npos) {
                    string key = val.substr(0, pos);
                    partmap.insert({key, val.substr(pos +1)});
                }
            }

            auto disk = make_value<map_value>();
            set<string> disks;
            ke = ks["sderr"];
            for (auto& kv : ke) {
                auto value = make_value<map_value>();
                string dname = kv.name();
                auto pos = dname.find(',');
                const string name = dname.substr(0, pos);

                string product = kv.value<string>("Product");
                string vendor = kv.value<string>("Vendor");
                string size = si_string(kv.value<uint64_t>("Size"));

                vector<string> parts;
                auto ret = partmap.equal_range(name);
                for (auto it = ret.first; it != ret.second; it++) {
                    parts.push_back(it->second);
                }
                value->add("partitions", make_value<string_value>(boost::join(parts, ",")));
                value->add("product", make_value<string_value>(move(product)));
                value->add("vendor", make_value<string_value>(move(vendor)));
                value->add("size", make_value<string_value>(move(size)));
                disk->add(name.c_str(), move(value));
                disks.insert(name);
            }
            facts.add(fact::disks, make_value<string_value>(boost::join(disks, ",")));
            facts.add(fact::disk, move(disk));
        } catch (kstat_exception& ex) {
            LOG_DEBUG("partition resolver failed (%1%)", ex.what());
        }
    }

}}}  // namespace facter::facts::solaris
