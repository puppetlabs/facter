#include <internal/facts/openbsd/memory_resolver.hpp>
#include <facter/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/types.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/sysctl.h>
#include <sys/swap.h>
#include <unistd.h>

using namespace std;
using namespace facter::execution;
using namespace facter::util;

namespace facter { namespace facts { namespace openbsd {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the system page size
        int pagesize_mib[] = { CTL_HW, HW_PAGESIZE};
        int page_size = 0;
        size_t len = sizeof(page_size);
        if (sysctl(pagesize_mib, 2, &page_size, &len, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): system page size is unknown.", strerror(errno), errno);
        } else {
            int uvmexp_mib[] = { CTL_VM, VM_UVMEXP };
            struct uvmexp uvmexp;
            len = sizeof(uvmexp);
            if (sysctl(uvmexp_mib, 2, &uvmexp, &len, nullptr, 0) == -1) {
                LOG_DEBUG("sysctl uvmexp failed: %1% (%2%): free memory is not available.", strerror(errno), errno);
            }

            // Should we account for the buffer cache?
            result.mem_total = static_cast<u_int64_t>(uvmexp.npages) << uvmexp.pageshift;
            result.mem_free = static_cast<u_int64_t>(uvmexp.free) << uvmexp.pageshift;
        }

        return result;
    }

}}}  // namespace facter::facts::openbsd
