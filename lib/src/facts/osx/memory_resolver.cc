#include <facter/facts/osx/memory_resolver.hpp>
#include <facter/execution/execution.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/regex.hpp>
#include <mach/mach.h>
#include <sys/types.h>
#include <sys/sysctl.h>

using namespace std;
using namespace facter::execution;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.osx.memory");

namespace facter { namespace facts { namespace osx {

    bool memory_resolver::get_memory_statistics(
            collection& facts,
            uint64_t& mem_free,
            uint64_t& mem_total,
            uint64_t& swap_free,
            uint64_t& swap_total)
    {
        // Get the total memory size
        int mib[] = { CTL_HW, HW_MEMSIZE };
        size_t size = sizeof(mem_total);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &mem_total, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): total memory size is not available.", strerror(errno), errno);
        }

        // Get the system page size
        mib[0] = CTL_HW;
        mib[1] = HW_PAGESIZE;
        uint32_t page_size = 0;
        size = sizeof(page_size);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &page_size, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): system page size is unknown.", strerror(errno), errno);
        } else {
            // Get the VM stats for free memory
            vm_statistics64 vm_stats;
            mach_msg_type_number_t type = HOST_VM_INFO64_COUNT;
            kern_return_t result = host_statistics64(mach_host_self(), HOST_VM_INFO64, reinterpret_cast<host_info64_t>(&vm_stats), &type);
            if (result != KERN_SUCCESS) {
                LOG_DEBUG("host_statistics64 failed: %1% (%2%): free memory size is not available.", mach_error_string(result), result);
            } else {
                // The free count already counts the free speculative pages
                // To be consistent with what Activity Monitor displays for the "used" amount,
                // subtract out those pages and only count the "completely free" pages.
                mem_free = (vm_stats.free_count - vm_stats.speculative_count) * page_size;
            }
        }

        // Get the swap usage statistics
        mib[0] = CTL_VM;
        mib[1] = VM_SWAPUSAGE;
        xsw_usage swap_usage;
        size = sizeof(swap_usage);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &swap_usage, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): swap usage is not available.", strerror(errno), errno);
        }

        swap_free = swap_usage.xsu_total - swap_usage.xsu_used;
        swap_total = swap_usage.xsu_total;
        return true;
    }

    posix::memory_resolver::encryption_status memory_resolver::get_swap_encryption_status()
    {
        // Get the swap usage statistics
        int mib[] = { CTL_VM, VM_SWAPUSAGE };
        xsw_usage swap_usage;
        size_t size = sizeof(swap_usage);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &swap_usage, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): encrypted swap information is not available.", strerror(errno), errno);
            return posix::memory_resolver::encryption_status::unknown;
        }
        return swap_usage.xsu_encrypted ? posix::memory_resolver::encryption_status::encrypted : posix::memory_resolver::encryption_status::not_encrypted;
    }

}}}  // namespace facter::facts::osx
