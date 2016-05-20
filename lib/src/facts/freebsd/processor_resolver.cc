#include <internal/facts/freebsd/processor_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/types.h>
#include <sys/sysctl.h>

using namespace std;

namespace facter { namespace facts { namespace freebsd {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);
        size_t len;
        int mib[2];
        mib[0] = CTL_HW;

        // Get the logical count of processors
        len = sizeof(result.logical_count);
        mib[1] = HW_NCPU;

        if (sysctl(mib, 2, &result.logical_count, &len, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl hw.ncpu failed: %1% (%2%): logical processor count is unavailable.", strerror(errno), errno);
        }

        // For each logical processor, collect the model name
        if (result.logical_count > 0) {
            // Note: we're using the same description string for all logical processors:
            // using different CPUs is not even likely to work.
            vector<char> buffer(256);

            while (true) {
                size_t size = buffer.size();
                mib[1] = HW_MODEL;
                if (sysctl(mib, 2, buffer.data(), &size, nullptr, 0) == 0) {
                    buffer.resize(size + 1);
                    result.models.resize(result.logical_count, buffer.data());
                    break;
                }
                if (errno != ENOMEM) {
                    LOG_DEBUG("sysctl hw.model failed: %1% (%2%): processor models are unavailable.", strerror(errno), errno);
                    break;
                }
                buffer.resize(buffer.size() * 2);
            }
        }

        // Set the speed
        len = sizeof(result.speed);

        int cmd[2];
        size_t two = 2;
        sysctlnametomib("hw.clockrate", cmd, &two);

        if (sysctl(cmd, 2, &result.speed, &len, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl hw.cpuspeed failed: %1% (%2%): processor speed is unavailable.", strerror(errno), errno);
        }
        // Scale the speed to something resolve() can correctly map
        result.speed *= 1000 * 1000;

        return result;
    }

}}}  // namespace facter::facts::freebsd
