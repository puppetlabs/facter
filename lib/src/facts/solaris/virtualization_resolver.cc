#include <internal/facts/solaris/virtualization_resolver.hpp>
#include <facter/facts/vm.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <map>

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace solaris {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // If in an LDom, the LDom facts will resolve and we can use them to identify
        // that we're in a virtual LDom environment. They should only resolve on SPARC.
        auto ldom_domainrole_control = facts.get<string_value>("ldom_domainrole_control");
        if (ldom_domainrole_control && ldom_domainrole_control->value() == "false") {
            auto ldom_domainrole_impl = facts.get<string_value>("ldom_domainrole_impl");
            if (ldom_domainrole_impl) {
                return ldom_domainrole_impl->value();
            }
        }

        // works for both x86 & sparc.
        auto exec = execute("/usr/bin/zonename");
        if (exec.success && exec.output != "global") {
            return vm::zone;
        }

        // Look for hypervisor matches based on other facts
        return get_fact_vm(facts);
    }
}}}  // namespace facter::facts::solaris
