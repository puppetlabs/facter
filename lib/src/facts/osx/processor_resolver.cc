#include <facter/facts/osx/processor_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/types.h>
#include <sys/sysctl.h>

using namespace std;

namespace facter { namespace facts { namespace osx {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);

        // Get the logical count of processors
        size_t size = sizeof(result.logical_count);
        if (sysctlbyname("hw.logicalcpu_max", &result.logical_count, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctlbyname failed: logical processor count is unavailable.", strerror(errno), errno);
        }

        // Get the physical count of processors
        size = sizeof(result.physical_count);
        if (sysctlbyname("hw.physicalcpu_max", &result.physical_count, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctlbyname failed: %1% (%2%): physical processor count is unavailable.", strerror(errno), errno);
        }

        // For each logical processor, collect the model name
        if (result.logical_count > 0) {
            // Note: we're using the same description string for all logical processors
            vector<char> buffer(256);

            while (true) {
                size_t size = buffer.size();
                if (sysctlbyname("machdep.cpu.brand_string", buffer.data(), &size, nullptr, 0) == 0) {
                    buffer.resize(size + 1);
                    result.models.resize(result.logical_count, buffer.data());
                    break;
                }
                if (errno != ENOMEM) {
                    LOG_DEBUG("sysctlbyname failed: %1% (%2%): processor models are unavailable.", strerror(errno), errno);
                    break;
                }
                buffer.resize(buffer.size() * 2);
            }
        }

        // Set the speed
        size = sizeof(result.speed);
        if (sysctlbyname("hw.cpufrequency_max", &result.speed, &size, nullptr, 0) == -1) {
            LOG_DEBUG("sysctlbyname failed: %1% (%2%): processor speed is unavailable.", strerror(errno), errno);
        }

        return result;
    }

}}}  // namespace facter::facts::osx
