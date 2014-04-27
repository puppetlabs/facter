#include <facter/facts/osx/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/facts/fact_map.hpp>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <cstring>

using namespace std;
using namespace facter::facts;

LOG_DECLARE_NAMESPACE("facts.osx.processor");

namespace facter { namespace facts { namespace osx {

    void processor_resolver::resolve_processors(fact_map& facts)
    {
        // Get the logical count of processors
        int logical_count = 0;
        size_t size = sizeof(logical_count);
        if (sysctlbyname("hw.logicalcpu_max", &logical_count, &size, nullptr, 0) != 0) {
            LOG_DEBUG("sysctlbyname failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::processor_count);
        } else {
            facts.add(fact::processor_count, make_value<string_value>(to_string(logical_count)));
        }

        // Get the physical count of processors
        int physical_count = 0;
        size = sizeof(physical_count);
        if (sysctlbyname("hw.physicalcpu_max", &physical_count, &size, nullptr, 0) != 0) {
            LOG_DEBUG("sysctlbyname failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::physical_processor_count);
        } else {
            facts.add(fact::physical_processor_count, make_value<string_value>(to_string(physical_count)));
        }

        // For each logical processor, output a fact with the model name
        if (logical_count > 0) {
            // Note: we're using the same description string for all the processor<num> facts
            vector<char> buffer(256);
            do {
                size_t size = buffer.size();
                if (sysctlbyname("machdep.cpu.brand_string", buffer.data(), &size, nullptr, 0) == 0) {
                    buffer.resize(size + 1);
                    break;
                }
                if (errno != ENOMEM) {
                    LOG_DEBUG("sysctlbyname failed: %1% (%2%): %3% facts are unavailable.", strerror(errno), errno, fact::processor);
                    return;
                }
                buffer.resize(buffer.size() * 2);
            } while (true);

            string description(buffer.data());
            for (int i = 0; i < logical_count; ++i) {
                facts.add(string(fact::processor) + to_string(i), make_value<string_value>(description));
            }
        }
    }

}}}  // namespace facter::facts::osx
