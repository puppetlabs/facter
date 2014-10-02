#include <facter/facts/posix/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <sys/utsname.h>

using namespace std;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("facts.posix.processor");

namespace facter { namespace facts { namespace posix {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;

        struct utsname name;
        memset(&name, 0, sizeof(name));
        if (uname(&name) == -1) {
            LOG_DEBUG("uname failed: %1% (%2%): hardware model is unavailable.", strerror(errno), errno);
        } else {
            result.hardware = name.machine;
        }

        // Unfortunately there's no corresponding member in utsname for "processor", so we need to spawn
        auto output = execute("uname", { "-p" });
        if (output.first) {
            result.isa = output.second;
        }

        // By default, the architecture is the same as the hardware model
        result.architecture = result.hardware;
        return result;
    }

}}}  // namespace facter::facts::posix
