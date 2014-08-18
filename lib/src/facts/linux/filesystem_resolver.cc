#include <facter/facts/linux/filesystem_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <facter/util/scoped_file.hpp>
#include <facter/util/file.hpp>
#include <boost/algorithm/string.hpp>
#include <mntent.h>
#include <sys/vfs.h>
#include <set>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.linux.filesystem");

namespace facter { namespace facts { namespace linux {

    void filesystem_resolver::resolve_mountpoints(collection& facts)
    {
        scoped_file file(setmntent("/etc/mtab", "r"));
        if (!static_cast<FILE*>(file)) {
            LOG_ERROR("setmntent failed: %1% (%2%): file system facts are unavailable.", strerror(errno), errno);
            return;
        }

        auto mountpoints = make_value<map_value>();

        mntent entry;
        char buffer[4096];
        while (mntent* ptr = getmntent_r(file, &entry, buffer, sizeof(buffer))) {
            // Skip over anything that doesn't map to a device
            if (!starts_with(ptr->mnt_fsname, "/dev/")) {
                continue;
            }

            uint64_t size = 0;
            uint64_t available = 0;
            struct statfs stats;
            if (statfs(ptr->mnt_dir, &stats) != -1) {
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
            value->add("filesystem", make_value<string_value>(ptr->mnt_type));
            value->add("device", make_value<string_value>(ptr->mnt_fsname));

            // Split the options based on ','
            auto options = make_value<array_value>();
            for (auto& option : split(ptr->mnt_opts, ',')) {
                options->add(make_value<string_value>(move(option)));
            }
            value->add("options", move(options));

            mountpoints->add(ptr->mnt_dir, move(value));
        }

        if (mountpoints->size() > 0) {
            facts.add(fact::mountpoints, move(mountpoints));
        }
    }

    void filesystem_resolver::resolve_filesystems(collection& facts)
    {
        set<string> filesystems;
        file::each_line("/proc/filesystems", [&](string& line) {
            trim(line);

            // Ignore lines without devices or fuseblk
            if (starts_with(line, "nodev") || line == "fuseblk") {
                return true;
            }

            filesystems.emplace(move(line));
            return true;
        });

        if (filesystems.size() > 0) {
            facts.add(fact::filesystems, make_value<string_value>(boost::join(filesystems, ",")));
        }
    }

    void filesystem_resolver::resolve_partitions(collection& facts)
    {
    }

}}}  // namespace facter::facts::linux
