#include <facter/facts/posix/virtualization_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <set>

#include "facter/facts/virtual_machine.hpp"

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace posix {

    virtualization_resolver::virtualization_resolver() :
        resolver(
            "virtualization",
            {
                fact::virtualization,
                fact::is_virtual,
            })
    {
    }

    void virtualization_resolver::resolve_facts(collection& facts)
    {
        string hypervisor = get_hypervisor(facts);
        if (hypervisor.empty()) {
            hypervisor = "physical";
        }
        facts.add(fact::is_virtual, make_value<boolean_value>(is_virtual(hypervisor)));
        facts.add(fact::virtualization, make_value<string_value>(move(hypervisor)));
    }

    bool virtualization_resolver::is_virtual(string const& hypervisor)
    {
        // Set of hypervisor values we consider to not be virtual
        static set<string> hypervisors = {
            "physical",
            string(vm::xen_privileged),
            string(vm::vmware_server),
            string(vm::vmware_workstation),
            string(vm::openvz_hn),
            string(vm::vserver_host),
        };
        return hypervisors.count(hypervisor) == 0;
    }

}}}  // namespace facter::facts::posix
