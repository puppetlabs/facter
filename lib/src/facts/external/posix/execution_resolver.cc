#include <facter/facts/external/execution_resolver.hpp>
#include <unistd.h>

using namespace std;

namespace facter { namespace facts { namespace external {

    bool execution_resolver::can_resolve(string const& path) const
    {
        return access(path.c_str(), X_OK) == 0;
    }

}}}  // namespace facter::facts::external
