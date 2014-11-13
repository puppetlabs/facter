#include <facter/facts/linux/filesystem_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/scoped_file.hpp>
#include <facter/util/file.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/lexical_cast.hpp>
#include <mntent.h>
#include <sys/vfs.h>
#include <set>
#include <map>

#ifdef USE_BLKID
#include <blkid/blkid.h>
#endif  // USE_BLKID

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace boost::filesystem;

using boost::lexical_cast;
using boost::bad_lexical_cast;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.linux.filesystem"

namespace facter { namespace facts { namespace linux {

    filesystem_resolver::data filesystem_resolver::collect_data(collection& facts)
    {
        data result;
        collect_mountpoint_data(result);
        collect_filesystem_data(result);
        collect_partition_data(result);
        return result;
    }

    void filesystem_resolver::collect_mountpoint_data(data& result)
    {
        // Populate the mountpoint data
        scoped_file file(setmntent("/etc/mtab", "r"));
        if (!static_cast<FILE *>(file)) {
            LOG_ERROR("setmntent failed: %1% (%2%): mountpoints are unavailable.", strerror(errno), errno);
            return;
        }
        mntent entry;
        char buffer[4096];
        while (mntent *ptr = getmntent_r(file, &entry, buffer, sizeof(buffer))) {
            // Skip over anything that doesn't map to a device
            if (!boost::starts_with(ptr->mnt_fsname, "/dev/")) {
                continue;
            }

            mountpoint point;
            point.name = ptr->mnt_dir;
            point.device = ptr->mnt_fsname;
            point.filesystem = ptr->mnt_type;
            boost::split(point.options, ptr->mnt_opts, boost::is_any_of(","), boost::token_compress_on);

            struct statfs stats;
            if (statfs(ptr->mnt_dir, &stats) != -1) {
                point.size = stats.f_frsize * stats.f_blocks;
                point.available = stats.f_frsize * stats.f_bfree;
            }

            result.mountpoints.emplace_back(move(point));
        }
    }

    void filesystem_resolver::collect_filesystem_data(data& result)
    {
        // Populate the partition data
        file::each_line("/proc/filesystems", [&](string &line) {
            boost::trim(line);

            // Ignore lines without devices or fuseblk
            if (boost::starts_with(line, "nodev") || line == "fuseblk") {
                return true;
            }

            result.filesystems.emplace(move(line));
            return true;
        });
    }

    void filesystem_resolver::collect_partition_data(data& result)
    {
        // Only return partition data if we're using libblkid
#ifdef USE_BLKID
        // The size of a block, in bytes, read in from /sys/class/block
        const int block_size = 512;

        // Get a default cache
        blkid_cache cache;
        if (blkid_get_cache(&cache, nullptr) < 0) {
            LOG_ERROR("blkid_get_cache failed: %1% (%2%): partition data is unavailable.", strerror(errno), errno);
            return;
        }

        // Probe all block devices
        if (blkid_probe_all(cache) < 0) {
            blkid_put_cache(cache);
            LOG_ERROR("blkid_probe_all failed: %1% (%2%): partition data is unavailable.", strerror(errno), errno);
            return;
        }

        // Begin iteration
        auto iter = blkid_dev_iterate_begin(cache);
        if (!iter) {
            blkid_put_cache(cache);
            LOG_ERROR("blkid_dev_iterate_begin failed: %1% (%2%): partition data is unavailable.", strerror(errno), errno);
            return;
        }

        // Populate a map of device -> mountpoint
        map<string, string> device_mountpoints;
        for (auto const& point : result.mountpoints) {
            device_mountpoints.insert(make_pair(point.device, point.name));
        }

        // Loop each block device
        blkid_dev device;
        while (blkid_dev_next(iter, &device) == 0) {
            partition part;
            part.name = blkid_dev_devname(device);

            // Populate the tags
            blkid_tag_iterate tag_iter;
            tag_iter = blkid_tag_iterate_begin(device);
            if (tag_iter) {
                const char* tag_name;
                const char* tag_value;
                while (blkid_tag_next(tag_iter, &tag_name, &tag_value) == 0) {
                    string* ptr = nullptr;
                    string attribute = tag_name;
                    boost::to_lower(attribute);
                    if (attribute == "type") {
                        ptr = &part.filesystem;
                    } else if (attribute == "partlabel") {
                        ptr = &part.label;
                    } else if (attribute == "uuid") {
                        ptr = &part.uuid;
                    } else if (attribute == "partuuid") {
                        ptr = &part.partuuid;
                    }
                    if (!ptr) {
                        continue;
                    }
                    (*ptr) = tag_value;
                }
                blkid_tag_iterate_end(tag_iter);
            }

            // Populate the size (the size is given in 512 byte blocks)
            string blocks = file::read((path("/sys/class/block") / path(part.name).filename() / "/size").string());
            boost::trim(blocks);
            if (!blocks.empty()) {
                try {
                    part.size = lexical_cast<uint64_t>(blocks) * block_size;
                } catch (bad_lexical_cast& ex) {
                }
            }

            // Populate the mountpoint if there is one
            auto it = device_mountpoints.find(part.name);
            if (it != device_mountpoints.end()) {
                part.mount = it->second;
            }

            result.partitions.emplace_back(move(part));
        }
        blkid_dev_iterate_end(iter);
        blkid_put_cache(cache);
#else
        LOG_INFO("partition information is unavailable: facter was built without blkid support.");
#endif  // USE_BLKID
    }

}}}  // namespace facter::facts::linux
