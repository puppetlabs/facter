#include <facter/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/file.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.external.powershell");

namespace facter { namespace facts { namespace external {

    bool powershell_resolver::can_resolve(string const& path) const
    {
        return boost::iends_with(string(path), ".ps1");
    }

    void powershell_resolver::resolve(string const& path, collection& facts) const
    {
        LOG_DEBUG("resolving facts from powershell script \"%1%\".", path);

        // TODO WINDOWS: Resolve facts by executing powershell script.

        LOG_DEBUG("completed resolving facts from powershell script \"%1%\".", path);
    }

}}}  // namespace facter::facts::external
