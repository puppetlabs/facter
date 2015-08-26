#include <internal/facts/aix/memory_resolver.hpp>
#include <internal/util/aix/odm.hpp>

#include <sys/vminfo.h>
#include <sys/cfgodm.h>
#include <sys/limits.h>
#include <system_error>

using namespace std;
using namespace facter::util::aix;

namespace facter { namespace facts { namespace aix {
    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;

        vminfo info;
        auto res = vmgetinfo(&info, VMINFO, sizeof(info));
        if (res < 0) {
            throw system_error(errno, system_category());
        }
        result.mem_total = info.memsizepgs * PAGE_SIZE;
        result.mem_free = info.numfrb * PAGE_SIZE;

        auto cu_at_query = odm_class<CuAt>::open("CuAt").query("value=paging and attribute=type");
        for (auto& cu_at : cu_at_query) {
            string device = string("/dev/") + cu_at.name;
            pginfo info;
            auto res = swapqry(const_cast<char*>(device.c_str()), &info);
            if (res < 0) {
                // it's really hard to tell from the ODM if a device
                // is a disk, just by its name. So we'll always try to
                // swapqry the things that have an attribute we
                // expect, but ignore any errno values that look like
                // "this just wasn't a good device to query"
                if (errno != ENODEV &&
                    errno != ENOENT &&
                    errno != ENOTBLK) {
                    throw system_error(errno, system_category());
                }
            }
            result.swap_total += info.size * PAGE_SIZE;
            result.swap_free += info.free * PAGE_SIZE;
        }

        return result;
    }
}}}  // namespace facter::facts::aix
