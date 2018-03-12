#include <internal/facts/aix/disk_resolver.hpp>
#include <internal/util/aix/odm.hpp>
#include <internal/util/posix/scoped_descriptor.hpp>
#include <leatherman/logging/logging.hpp>

#include <fcntl.h>
#include <odmi.h>
#include <sys/cfgodm.h>
#include <sys/ioctl.h>
#include <sys/devinfo.h>

using namespace facter::util::aix;
using namespace facter::util::posix;
using namespace std;

namespace facter { namespace facts { namespace aix {

    disk_resolver::data disk_resolver::collect_data(collection& facts)
    {
        data result;
        vector<string> disk_types;
        auto pd_dv_query = odm_class<PdDv>::open("PdDv").query("class=disk");
        for (auto& pd_dv : pd_dv_query) {
            LOG_DEBUG("got a disk type: {1}", pd_dv.uniquetype);
            disk_types.push_back(pd_dv.uniquetype);
        }

        auto cu_dv = odm_class<CuDv>::open("CuDv");
        for (string& type : disk_types) {
            string query = (boost::format("PdDvLn=%1%") % type).str();
            auto cu_dv_query = cu_dv.query(query);
            for (auto& cu_dv : cu_dv_query) {
                LOG_DEBUG("got a disk: {1}", cu_dv.name);
                disk d;
                d.name = cu_dv.name;

                {
                    string device = (boost::format("/dev/%1%") % d.name).str();
                    auto descriptor = open(device.c_str(), O_RDONLY);
                    if (descriptor < 0) {
                        LOG_DEBUG("Could not open device %1% for reading: %2% (%3%). Disk facts will not be populated for this device", d.name, strerror(errno), errno);
                        continue;
                    }
                    scoped_descriptor fd(descriptor);
                    devinfo info;
                    auto result = ioctl(fd, IOCINFO, &info);
                    if (result < 0) {
                        LOG_DEBUG("Ioctl IOCINFO failed for device %1%: %2% (%3%). Disk facts will not be populated for this device", d.name, strerror(errno), errno);
                        continue;
                    }
                    switch (info.devtype) {
                    case DD_DISK:
                    case DD_SCDISK:
                        if (info.flags & DF_LGDSK) {
                            d.size = (uint32_t)info.un.scdk64.hi_numblks;
                            d.size <<= 32;
                            d.size |= (uint32_t)info.un.scdk64.lo_numblks;
                            d.size *= info.un.scdk64.blksize;
                        } else {
                            d.size = (uint32_t)info.un.scdk.numblks;
                            d.size *= info.un.scdk.blksize;
                        }
                        break;
                    default:
                        LOG_WARNING("Expected a Disk or SCSI disk device, got device code '{1}'. This is probably a Facter bug. Please report it, and include this error message.", info.devtype);
                        break;
                    }
                }
                result.disks.emplace_back(move(d));
            }
        }

        return result;
    }
}}}  // namespace facter::facts::aix
