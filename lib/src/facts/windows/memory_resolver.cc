#include <facter/facts/windows/memory_resolver.hpp>
#include <facter/util/windows/system_error.hpp>
#include <facter/util/windows/windows.hpp>
#include <facter/logging/logging.hpp>
#include <psapi.h>

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.memory_resolver"

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
