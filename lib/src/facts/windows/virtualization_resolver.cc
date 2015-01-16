#include <facter/facts/windows/virtualization_resolver.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/util/windows/wmi.hpp>
#include <facter/logging/logging.hpp>
#include <vector>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    virtualization_resolver::virtualization_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::virtualization_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // TODO: This is probably not equivalent to line 194 of
        // https://github.com/puppetlabs/facter/blob/master/lib/facter/virtual.rb
        // Explore whether it can work, or if we need another wmi query
        static vector<tuple<string, string>> vms = {
            make_tuple("VirtualBox",        string(vm::virtualbox)),
            make_tuple("VMware",            string(vm::vmware)),
            make_tuple("KVM",               string(vm::kvm)),
            make_tuple("Bochs",             string(vm::bochs)),
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

        return {};
    }

}}}  // namespace facter::facts::windows
