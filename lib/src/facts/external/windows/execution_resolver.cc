#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <facter/execution/execution.hpp>

using namespace std;
using namespace facter::execution;
using namespace facter::facts;
using namespace facter::facts::external;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.external.execution.posix");

namespace facter { namespace facts { namespace external {

    bool execution_resolver::can_resolve(string const& path) const
    {
        // TODO WINDOWS: Implement function.
        return false;
    }

}}}  // namespace facter::facts::external
