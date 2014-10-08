#include <facter/facts/windows/memory_resolver.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <facter/logging/logging.hpp>
#include <windows.h>
#include <psapi.h>

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.memory_resolver"

using namespace facter::util;

namespace facter { namespace facts { namespace windows {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        PERFORMANCE_INFORMATION statex;
        if (!GetPerformanceInfo(&statex, sizeof(statex))) {
            auto err = GetLastError();
            LOG_DEBUG("resolving memory facts failed: %1% (%2%)", scoped_error(err), err);
            return {};
        }

        data result;
        result.mem_total = statex.PhysicalTotal*statex.PageSize;
        result.mem_free = statex.PhysicalAvailable*statex.PageSize;
        result.swap_total = (statex.CommitLimit - statex.PhysicalTotal)*statex.PageSize;
        return result;
    }

}}}  // namespace facter::facts::windows
