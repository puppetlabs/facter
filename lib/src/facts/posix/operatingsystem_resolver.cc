#include <internal/facts/posix/operating_system_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/execution/execution.hpp>
#include <sys/utsname.h>

using namespace std;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace posix {

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = resolvers::operating_system_resolver::collect_data(facts);

        struct utsname name;
        memset(&name, 0, sizeof(name));
        if (uname(&name) == -1) {
            LOG_DEBUG("uname failed: %1% (%2%): OS hardware is unavailable.", strerror(errno), errno);
        } else {
            result.hardware = name.machine;
        }

        // By default, the architecture is the same as the hardware model
        result.architecture = result.hardware;
        return result;
    }

}}}  // namespace facter::facts::posix
