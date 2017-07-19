#include <leatherman/execution/execution.hpp>

#include <internal/facts/freebsd/operating_system_resolver.hpp>

using namespace std;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace freebsd {

    void operating_system_resolver::collect_release_data(collection& facts, data& result)
    {
        auto exec = execute("freebsd-version");
        if (exec.success) {
            result.release = exec.output;
        }
    }
} } }  // namespace facter::facts::freebsd
