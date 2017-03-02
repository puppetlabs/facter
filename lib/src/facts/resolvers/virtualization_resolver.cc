#include <internal/facts/resolvers/virtualization_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/vm.hpp>
#include <set>

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace resolvers {

    virtualization_resolver::virtualization_resolver() :
        resolver(
            "virtualization",
            {
                fact::virtualization,
                fact::is_virtual,
                fact::cloud
            })
    {
    }

    void virtualization_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        facts.add(fact::is_virtual, make_value<boolean_value>(data.is_virtual));
        facts.add(fact::virtualization, make_value<string_value>(data.hypervisor));
        if (!data.cloud.provider.empty()) {
            auto cloud = make_value<map_value>();
            cloud->add("provider", make_value<string_value>(data.cloud.provider));
            facts.add(fact::cloud, move(cloud));
        }
    }

    data virtualization_resolver::collect_data(collection& facts)
    {
        data data;
        auto hypervisor = get_hypervisor(facts);

        if (hypervisor.empty()) {
            hypervisor = "physical";
        }

        auto cloud_provider = get_cloud_provider(facts);
        data.is_virtual = is_virtual(hypervisor);
        data.hypervisor = hypervisor;
        data.cloud.provider = cloud_provider;
        return data;
    }

    string virtualization_resolver::get_cloud_provider(collection& facts)
    {
        // Default implementation for other resolvers.
        return "";
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

    string virtualization_resolver::get_product_name_vm(string const& product_name)
    {
        static vector<tuple<string, string>> vms = {
            make_tuple("VMware",            string(vm::vmware)),
            make_tuple("VirtualBox",        string(vm::virtualbox)),
            make_tuple("Parallels",         string(vm::parallels)),
            make_tuple("KVM",               string(vm::kvm)),
            make_tuple("Virtual Machine",   string(vm::hyperv)),
            make_tuple("RHEV Hypervisor",   string(vm::redhat_ev)),
            make_tuple("oVirt Node",        string(vm::ovirt)),
            make_tuple("HVM domU",          string(vm::xen_hardware)),
            make_tuple("Bochs",             string(vm::bochs)),
        };

        for (auto const& vm : vms) {
            if (product_name.find(get<0>(vm)) != string::npos) {
                return get<1>(vm);
            }
        }
        return {};
    }

}}}  // namespace facter::facts::resolvers
