#include <internal/facts/windows/virtualization_resolver.hpp>
#include <leatherman/windows/wmi.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <leatherman/logging/logging.hpp>
#include <vector>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace leatherman::windows;

namespace facter { namespace facts { namespace windows {

    virtualization_resolver::virtualization_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::virtualization_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        static vector<tuple<string, string>> vms = {
            make_tuple("VirtualBox",        string(vm::virtualbox)),
            make_tuple("VMware",            string(vm::vmware)),
            make_tuple("KVM",               string(vm::kvm)),
            make_tuple("Bochs",             string(vm::bochs)),
            make_tuple("Google",            string(vm::gce)),
            make_tuple("OpenStack",         string(vm::openstack)),
        };

        auto vals = _wmi->query(wmi::computersystem, {wmi::manufacturer, wmi::model});
        if (vals.empty()) {
            return {};
        }

        auto &manufacturer = wmi::get(vals, wmi::manufacturer);
        auto &model = wmi::get(vals, wmi::model);

        for (auto const& vm : vms) {
            if (model.find(get<0>(vm)) != string::npos) {
                return get<1>(vm);
            }
        }

        if (model.find("Virtual Machine") != string::npos && manufacturer.find("Microsoft") != string::npos) {
            return vm::hyperv;
        }

        if (manufacturer.find("Xen") != string::npos) {
            return vm::xen;
        }

        if (manufacturer.find("Amazon EC2") != string::npos) {
            return vm::kvm;
        }

        return {};
    }

}}}  // namespace facter::facts::windows
