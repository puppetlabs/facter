#include <internal/facts/osx/memory_resolver.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <mach/mach.h>
#include <sys/sysctl.h>

using namespace std;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace osx {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the total memory size
        int mib[] = { CTL_HW, HW_MEMSIZE };
        size_t size = sizeof(result.mem_total);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &result.mem_total, &size, nullptr, 0) == -1) {
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
            kern_return_t err = host_statistics64(mach_host_self(), HOST_VM_INFO64, reinterpret_cast<host_info64_t>(&vm_stats), &type);
            if (err != KERN_SUCCESS) {
                LOG_DEBUG("host_statistics64 failed: %1% (%2%): free memory size is not available.", mach_error_string(err), err);
            } else {
                // The free count already counts the free speculative pages
                // To be consistent with what Activity Monitor displays for the "used" amount,
                // subtract out those pages and only count the "completely free" pages.
                result.mem_free = (vm_stats.free_count - vm_stats.speculative_count) * page_size;
            }
        }

        // Get the swap usage statistics
        mib[0] = CTL_VM;
        mib[1] = VM_SWAPUSAGE;
        xsw_usage swap_usage;
        size = sizeof(swap_usage);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &swap_usage, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): swap data is not available.", strerror(errno), errno);
        } else {
            result.swap_free = swap_usage.xsu_total - swap_usage.xsu_used;
            result.swap_total = swap_usage.xsu_total;
            result.swap_encryption = swap_usage.xsu_encrypted ? encryption_status::encrypted : encryption_status::not_encrypted;
        }
        return result;
    }

}}}  // namespace facter::facts::osx
