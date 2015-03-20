#include <internal/facts/windows/memory_resolver.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <psapi.h>

using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        PERFORMANCE_INFORMATION statex;
        if (!GetPerformanceInfo(&statex, sizeof(statex))) {
            LOG_DEBUG("resolving memory facts failed: %1%", system_error());
            return {};
        }

        data result;
        result.mem_total = statex.PhysicalTotal*statex.PageSize;
        result.mem_free = statex.PhysicalAvailable*statex.PageSize;
        return result;
    }

}}}  // namespace facter::facts::windows
