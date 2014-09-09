#include <facter/facts/external/execution_resolver.hpp>

namespace facter { namespace facts { namespace external {

    bool execution_resolver::can_resolve(std::string const& path) const
    {
        // TODO WINDOWS: Implement function.
        return false;
    }

}}}  // namespace facter::facts::external
