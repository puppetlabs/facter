#include <facter/facts/windows/virtualization_resolver.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <vector>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

namespace facter { namespace facts { namespace windows {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // TODO: This is probably not equivalent to line 194 of
        // https://github.com/puppetlabs/facter/blob/master/lib/facter/virtual.rb
        // Explore whether it can work, or if we need another wmi query
        static vector<tuple<string, string>> vms = {
            make_tuple("VirtualBox",        string(vm::virtualbox)),
            make_tuple("Virtual Machine",   string(vm::hyperv)),
            make_tuple("VMware",            string(vm::vmware)),
            make_tuple("KVM",               string(vm::kvm)),
            make_tuple("Bochs",             string(vm::bochs)),
            make_tuple("Parallels",         string(vm::parallels)),
            make_tuple("RHEV Hypervisor",   string(vm::redhat_ev)),
            make_tuple("oVirt Node",        string(vm::ovirt)),
            make_tuple("HVM domU",          string(vm::xen_hardware)),
        };

        auto product_name = facts.get<string_value>(fact::product_name);
        if (!product_name) {
            return {};
        }

        auto const& value = product_name->value();

        for (auto const& vm : vms) {
            if (value.find(get<0>(vm)) != string::npos) {
                return get<1>(vm);
            }
        }

        return {};
    }

}}}  // namespace facter::facts::windows
