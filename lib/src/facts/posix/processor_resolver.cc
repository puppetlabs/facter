#include <internal/facts/posix/processor_resolver.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>

using namespace std;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace posix {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;

        // Unfortunately there's no corresponding member in utsname for "processor", so we need to spawn
        auto exec = execute("uname", { "-p" });
        if (exec.success) {
            result.isa = exec.output;
        }
        return result;
    }

}}}  // namespace facter::facts::posix
