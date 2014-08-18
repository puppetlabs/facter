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
#include <boost/filesystem.hpp>
#include <boost/lexical_cast.hpp>
#include <mntent.h>
#include <sys/vfs.h>
#include <blkid/blkid.h>
#include <set>
#include <map>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace boost::filesystem;

using boost::lexical_cast;
using boost::bad_lexical_cast;

LOG_DECLARE_NAMESPACE("facts.linux.filesystem");

namespace facter { namespace facts { namespace linux {

    void filesystem_resolver::resolve_mountpoints(collection& facts)
    {
        scoped_file file(setmntent("/etc/mtab", "r"));
        if (!static_cast<FILE*>(file)) {
            LOG_ERROR("setmntent failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::mountpoints);
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
        auto partitions = make_value<map_value>();

        // Get a default cache
        blkid_cache cache;
        if (blkid_get_cache(&cache, nullptr) < 0) {
            LOG_ERROR("blkid_get_cache failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::partitions);
            return;
        }

        // Probe all block devices
        if (blkid_probe_all(cache) < 0) {
            blkid_put_cache(cache);
            LOG_ERROR("blkid_probe_all failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::partitions);
            return;
        }

        // Begin iteration
        auto iter = blkid_dev_iterate_begin(cache);
        if (!iter) {
            blkid_put_cache(cache);
            LOG_ERROR("blkid_dev_iterate_begin failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::partitions);
            return;
        }

        // Populate a map of device -> mountpoint
        map<string, string> device_mountpoints;
        auto mountpoints = facts.get<map_value>(fact::mountpoints, false);
        if (mountpoints) {
            mountpoints->each([&](string const& name, value const* val) {
                auto mountpoint = dynamic_cast<map_value const*>(val);
                if (!mountpoint) {
                    return true;
                }
                auto device = mountpoint->get<string_value>("device");
                if (!device) {
                    return true;
                }
                // Take the first mapping only
                device_mountpoints.insert(make_pair(device->value(), name));
                return true;
            });
        }

        // Loop each block device
        blkid_dev device;
        while (blkid_dev_next(iter, &device) == 0) {
            auto partition = make_value<map_value>();

            string device_name = blkid_dev_devname(device);

            // Populate the tags
            blkid_tag_iterate tag_iter;
            tag_iter = blkid_tag_iterate_begin(device);
            if (tag_iter) {
                const char* tag_name;
                const char* tag_value;
                while (blkid_tag_next(tag_iter, &tag_name, &tag_value) == 0) {
                    string attribute = to_lower(tag_name);
                    if (attribute == "type") {
                        attribute = "filesystem";
                    } else if (attribute == "partlabel") {
                        attribute = "label";
                    }
                    partition->add(move(attribute), make_value<string_value>(tag_value));
                }
                blkid_tag_iterate_end(tag_iter);
            }

            // Populate the size
            string size = trim(file::read((path("/sys/class/block") / path(device_name).filename() / "/size").string()));
            if (!size.empty()) {
                try {
                    partition->add("size", make_value<integer_value>(lexical_cast<uint64_t>(size)));
                } catch (bad_lexical_cast& ex) {
                }
            }

            // Populate the mountpoint if there is one
            auto it = device_mountpoints.find(device_name);
            if (it != device_mountpoints.end()) {
                partition->add("mount", make_value<string_value>(it->second));
            }

            partitions->add(move(device_name), move(partition));
        }
        blkid_dev_iterate_end(iter);
        blkid_put_cache(cache);

        if (partitions->size() > 0) {
            facts.add(fact::partitions, move(partitions));
        }
    }

}}}  // namespace facter::facts::linux
