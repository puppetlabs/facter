#include <facter/facts/windows/memory_resolver.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <facter/logging/logging.hpp>
#include <windows.h>

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.memory_resolver"

using namespace facter::util;

namespace facter { namespace facts { namespace windows {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;

        MEMORYSTATUSEX statex;
        statex.dwLength = sizeof(statex);
        if (!GlobalMemoryStatusEx(&statex)) {
            auto err = GetLastError();
            LOG_WARNING("resolving memory facts failed: %1% (%2%)", scoped_error(err), err);
            return result;
        }

        result.mem_total = statex.ullTotalPhys;
        result.mem_free = statex.ullAvailPhys;
        return result;
    }

}}}  // namespace facter::facts::windows
