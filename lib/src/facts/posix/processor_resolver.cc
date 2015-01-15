#include <facter/facts/posix/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>

using namespace std;
using namespace facter::execution;

namespace facter { namespace facts { namespace posix {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;

        // Unfortunately there's no corresponding member in utsname for "processor", so we need to spawn
        auto output = execute("uname", { "-p" });
        if (output.first) {
            result.isa = output.second;
        }
        return result;
    }

}}}  // namespace facter::facts::posix
