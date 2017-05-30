#include <internal/facts/aix/filesystem_resolver.hpp>
#include <internal/util/aix/odm.hpp>
#include <internal/util/aix/vmount.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>

#include <boost/algorithm/string.hpp>

#include <map>
#include <string>
#include <vector>

#include <lvm.h>
#include <odmi.h>
#include <sys/cfgodm.h>
#include <sys/statfs.h>

using namespace std;
using namespace facter::util::aix;
namespace fu = leatherman::file_util;

namespace facter { namespace facts { namespace aix {
    filesystem_resolver::data filesystem_resolver::collect_data(collection& facts)
    {
        data result;
        collect_filesystem_data(result);
        collect_mountpoint_data(result);
        collect_partition_data(result);
        return result;
    }

    void filesystem_resolver::collect_filesystem_data(data& result)
    {
        fu::each_line("/etc/vfs", [&](const string& line) {
            auto first_char = line.find_first_not_of(" \t");
            if (first_char != string::npos &&  // skip completely blank lines
                line[first_char] != '#' &&  // skip comment lines
                line[first_char] != '%')  {  // skip defaultvfs line
                vector<string> tokens;
                boost::split(tokens, line, boost::is_space(), boost::token_compress_on);
                _filesystems.emplace(make_pair(stoul(tokens[1]), tokens[0]));
                result.filesystems.emplace(move(tokens[0]));
            }
            return true;
        });
    }

    void filesystem_resolver::collect_mountpoint_data(data& result)
    {
        for (const auto& mount : mountctl()) {
            mountpoint m;
            if (mount.vmt_gfstype == MNT_PROCFS) {
                continue;
            }
            m.filesystem = _filesystems[mount.vmt_gfstype];
            m.device = reinterpret_cast<char*>(vmt2dataptr(&mount, VMT_OBJECT));
            m.name = reinterpret_cast<char*>(vmt2dataptr(&mount, VMT_STUB));

            string opts = reinterpret_cast<char*>(vmt2dataptr(&mount, VMT_ARGS));
            boost::split(m.options, opts, boost::is_any_of(","));

            struct statfs64 fs;
            if (0 != statfs64(const_cast<char*>(m.name.c_str()), &fs)) {
                LOG_WARNING("Could not get fs data for {1}: {2}", m.name, errno);
            } else {
                m.size = fs.f_bsize*fs.f_blocks;
                m.available = fs.f_bsize*fs.f_bfree;
            }

            _mounts[m.device] = m.name;
            result.mountpoints.emplace_back(move(m));
        }
    }

    void filesystem_resolver::collect_partition_data(data& result)
    {
        auto cu_dv = odm_class<CuDv>::open("CuDv");
        auto cu_at = odm_class<CuAt>::open("CuAt");
        for (auto& dv : cu_dv.query("PdDvLn=logical_volume/lvsubclass/lvtype")) {
            partition p;
            p.name = string("/dev/") + dv.name;

            string query = (boost::format("name=%1%") % dv.name).str();
            for (auto& at : cu_at.query(query)) {
                if (0 == strcmp(at.attribute, "label")) {
                    p.label = at.value;
                } else if (0 == strcmp(at.attribute, "lvserial_id")) {
                    struct lv_id id;
                    // AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDD.EEEE format
                    // First four chunks are hexadecimal 32-bit integers.
                    // After the dot is a decimal integer
                    // Volume groups from the 90s only have 64-bit IDs,
                    // rather than the full 128.

                    auto vgid = string(at.value);
                    auto length = vgid.find_first_of('.');
                    id.vg_id.word1 = stoul(vgid.substr(0, 8), nullptr, 16);
                    id.vg_id.word2 = stoul(vgid.substr(8, 8), nullptr, 16);
                    if (length == 32) {
                        id.vg_id.word3 = stoul(vgid.substr(16, 8), nullptr, 16);
                        id.vg_id.word4 = stoul(vgid.substr(24, 8), nullptr, 16);
                    }
                    id.minor_num = stoul(vgid.substr(length+1, string::npos), nullptr, 10);

                    struct querylv* lv;
                    if (0 != lvm_querylv(&id, &lv, nullptr)) {
                        LOG_WARNING("Could not get info for partition '{1}' from the LVM subsystem", p.name);
                    } else if (!lv) {
                        LOG_WARNING("querylv returned success but we got a null LV. WTF?");
                    } else {
                        // Size is calculated as "currentsize * 2^ppsize".
                        p.size = lv->currentsize;
                        p.size <<= lv->ppsize;
                    }
                } else if (0 == strcmp(at.attribute, "type")) {
                    p.filesystem = at.value;
                }
            }

            p.mount = _mounts[p.name];
            result.partitions.emplace_back(move(p));
        }
    }
}}}
