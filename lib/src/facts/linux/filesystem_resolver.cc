#include <internal/facts/linux/filesystem_resolver.hpp>
#include <internal/util/scoped_file.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
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
namespace sys = boost::system;
namespace lth_file = leatherman::file_util;
using namespace leatherman::util;

using boost::lexical_cast;
using boost::bad_lexical_cast;

namespace facter { namespace facts { namespace linux {

    string filesystem_resolver::safe_convert(char const* value)
    {
        string result;

        if (value) {
            while (*value) {
                unsigned char c = static_cast<unsigned char>(*value);
                if (c >= 128) {
                    result += "M-";
                    c -= 128;
                }
                if (c < 32 || c == 0xf7) {
                    result += '^';
                    c ^= 0x40;
                } else if (c == '"' || c == '\\') {
                    result += '\\';
                }
                result += static_cast<char>(c);
                ++value;
            }
        }
        return result;
    }

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
            LOG_ERROR("setmntent failed: {1} ({2}): mountpoints are unavailable.", strerror(errno), errno);
            return;
        }
        string root_device;
        mntent entry;
        char buffer[4096];
        map<string, mountpoint> mountpoints_map;
        while (mntent *ptr = getmntent_r(file, &entry, buffer, sizeof(buffer))) {
            string device = ptr->mnt_fsname;
            string mtype = ptr->mnt_type;

            // Skip over any non-tmpfs mount under /proc or /sys
            if (mtype != "tmpfs" && (boost::starts_with(ptr->mnt_dir, "/proc") || boost::starts_with(ptr->mnt_dir, "/sys"))) {
                continue;
            }

            // If the "root" device, lookup the actual device from the kernel options
            // This is done because not all systems symlink /dev/root
            if (device == "/dev/root") {
                if (root_device.empty()) {
                    boost::regex root_pattern("root=([^\\s]+)");
                    lth_file::each_line("/proc/cmdline", [&](string& line) {
                        if (re_search(line, root_pattern, &root_device)) {
                            return false;
                        }
                        return true;
                    });
                }
                if (!root_device.empty()) {
                    device = root_device;
                }
            }

            mountpoint point;
            point.name = ptr->mnt_dir;
            point.device = std::move(device);
            point.filesystem = ptr->mnt_type;
            boost::split(point.options, ptr->mnt_opts, boost::is_any_of(","), boost::token_compress_on);

            struct statfs stats;
            if (statfs(ptr->mnt_dir, &stats) != -1) {
                point.size = (static_cast<uint64_t>(stats.f_frsize)
                              * static_cast<uint64_t>(stats.f_blocks));
                point.available = (static_cast<uint64_t>(stats.f_frsize)
                                   * static_cast<uint64_t>(stats.f_bfree));
            }

            auto iterator = mountpoints_map.find(point.name);
            if (iterator != mountpoints_map.end()){
                if (boost::starts_with(point.device, "/dev/") || point.filesystem == "tmpfs")
                    iterator->second = point;
            } else {
                mountpoints_map[point.name] = point;
            }
        }

        result.mountpoints.reserve(mountpoints_map.size());
        for_each(mountpoints_map.begin(), mountpoints_map.end(),
            [&](const map<string, mountpoint>::value_type& p)
            { result.mountpoints.emplace_back(p.second); });
    }

    void filesystem_resolver::collect_filesystem_data(data& result)
    {
        // Populate the partition data
        lth_file::each_line("/proc/filesystems", [&](string &line) {
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
        // Populate a map of device -> mountpoint
        map<string, string> mountpoints;
        for (auto const& point : result.mountpoints) {
            mountpoints.insert(make_pair(point.device, point.name));
        }

        void* cache = nullptr;

#ifdef USE_BLKID
        blkid_cache actual = nullptr;
        if (blkid_get_cache(&actual, "/dev/null") == 0) {
            // Do a probe since we're not using a cache file
            if (blkid_probe_all(actual) != 0) {
                LOG_DEBUG("blkid_probe_all failed: partition attributes are not available.");
                blkid_put_cache(actual);
                actual = nullptr;
            }
            cache = actual;
        } else {
            LOG_DEBUG("blkid_get_cache failed: partition attributes are not available.");
        }
#else
        LOG_DEBUG("facter was built without libblkid support: partition attributes are not available.");
#endif  // USE_BLKID

        lth_file::each_subdirectory("/sys/block", [&](string const& subdirectory) {
            path block_device_path(subdirectory);
            auto block_device_filename = block_device_path.filename().string();

            // For devices, look up partition subdirectories
            sys::error_code ec;
            if (is_directory(block_device_path / "device", ec)) {
                lth_file::each_subdirectory(subdirectory, [&](string const& subdirectory) {
                    path partition_path(subdirectory);
                    auto partition_name = partition_path.filename().string();

                    // Ignore any subdirectory that does not start with the device file name
                    if (!boost::starts_with(partition_name, block_device_filename)) {
                        return true;
                    }

                    partition part;
                    part.name = "/dev/" + partition_name;
                    populate_partition_attributes(part, subdirectory, cache, mountpoints);
                    result.partitions.emplace_back(std::move(part));
                    return true;
                });
            } else if (is_directory(block_device_path / "dm", ec)) {
                // For mapped devices, lookup the mapping name
                partition part;
                string mapping_name = lth_file::read((block_device_path / "dm" / "name").string());
                boost::trim(mapping_name);
                if (mapping_name.empty()) {
                    mapping_name = "/dev/" + block_device_filename;
                } else {
                    mapping_name = "/dev/mapper/" + mapping_name;
                }
                part.name = std::move(mapping_name);

                populate_partition_attributes(part, block_device_path.string(), cache, mountpoints);
                result.partitions.emplace_back(std::move(part));
            } else if (is_directory(block_device_path / "loop")) {
                // Lookup the backing file
                partition part;
                part.name = "/dev/" + block_device_filename;
                part.backing_file = lth_file::read((block_device_path / "loop" / "backing_file").string());
                boost::trim(part.backing_file);

                populate_partition_attributes(part, block_device_path.string(), cache, mountpoints);
                result.partitions.emplace_back(std::move(part));
            }
            return true;
        });

#ifdef USE_BLKID
        // Cleanup the blkid cache if there is one
        if (cache) {
            blkid_put_cache(static_cast<blkid_cache>(cache));
            cache = nullptr;
        }
#endif  // USE_BLKID
    }

    void filesystem_resolver::populate_partition_attributes(partition& part, string const& device_directory, void* cache, map<string, string> const& mountpoints)
    {
#ifdef USE_BLKID
        if (cache) {
            auto device = blkid_get_dev(static_cast<blkid_cache>(cache), part.name.c_str(), 0);
            if (!device) {
                LOG_DEBUG("blkid_get_dev failed: partition attributes are unavailable for '{1}'.", part.name);
            } else {
                // Populate the attributes
                auto it = blkid_tag_iterate_begin(device);
                if (it) {
                    const char* name;
                    const char* value;
                    while (blkid_tag_next(it, &name, &value) == 0) {
                        string* ptr = nullptr;
                        string attribute = name;
                        boost::to_lower(attribute);
                        if (attribute == "type") {
                            ptr = &part.filesystem;
                        } else if (attribute == "label") {
                            ptr = &part.label;
                        } else if (attribute == "partlabel") {
                            ptr = &part.partition_label;
                        } else if (attribute == "uuid") {
                            ptr = &part.uuid;
                        } else if (attribute == "partuuid") {
                            ptr = &part.partition_uuid;
                        }
                        if (!ptr) {
                            continue;
                        }
                        (*ptr) = safe_convert(value);
                    }
                    blkid_tag_iterate_end(it);
                }
            }
        }
#endif  // USE_BLKID

        // Lookup the mountpoint
        auto it = mountpoints.find(part.name);
        if (it != mountpoints.end()) {
            part.mount = it->second;
        }

        // The size of a block, in bytes
        const int block_size = 512;

        // Read the size
        string blocks = lth_file::read(device_directory + "/size");
        boost::trim(blocks);
        if (!blocks.empty()) {
            try {
                part.size = lexical_cast<uint64_t>(blocks) * block_size;
            } catch (bad_lexical_cast& ex) {
                LOG_DEBUG("cannot determine size of partition '{1}': '{2}' is not an integral value.", part.name, blocks);
            }
        }
    }

}}}  // namespace facter::facts::linux

