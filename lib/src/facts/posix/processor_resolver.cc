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
        bool success;
        string output, none;
        tie(success, output, none) = execute("uname", { "-p" });
        if (success) {
            result.isa = output;
        }
        return result;
    }

}}}  // namespace facter::facts::posix
