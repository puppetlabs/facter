#include <internal/facts/aix/memory_resolver.hpp>
#include <internal/util/aix/odm.hpp>

#include <leatherman/logging/logging.hpp>
#include <sys/vminfo.h>
#include <sys/cfgodm.h>
#include <sys/limits.h>
#include <system_error>

using namespace std;
using namespace facter::util::aix;

// This routine is useful to encapsulate knowledge of the PAGE_SIZE
// in one place and to also handle implicit conversions of numeric
// values to uint64_t, which is what we use to represent bytes. Otherwise,
// we risk accidentally capturing an overflowed value in our computed
// memory facts.
static uint64_t pages_to_bytes(uint64_t num_pages) {
    return num_pages * PAGE_SIZE;
}

namespace facter { namespace facts { namespace aix {
    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;

        vminfo info;
        auto res = vmgetinfo(&info, VMINFO, sizeof(info));
        if (res < 0) {
            throw system_error(errno, system_category());
        }
        result.mem_total = pages_to_bytes(info.memsizepgs);
        result.mem_free = pages_to_bytes(info.numfrb);

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
                // ENXIO: No such device address.
                if (errno != ENODEV &&
                    errno != ENOENT &&
                    errno != ENOTBLK &&
                    errno != ENXIO) {
                    throw system_error(errno, system_category(), device);
                } else {
                    LOG_DEBUG("cannot use device {1}: error is {2}", device, errno);
                }
            }

            result.swap_total += pages_to_bytes(info.size);
            result.swap_free += pages_to_bytes(info.free);
        }

        return result;
    }
}}}  // namespace facter::facts::aix
