#include <internal/facts/openbsd/virtualization_resolver.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <leatherman/execution/execution.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace openbsd {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        return get_fact_vm(facts);
    }

} } }  // namespace facter::facts::openbsd
