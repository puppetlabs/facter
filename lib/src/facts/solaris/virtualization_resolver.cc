#include <facter/facts/solaris/virtualization_resolver.hpp>
#include <facter/facts/vm.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/util/regex.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <map>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace solaris {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // works for both x86 & sparc.
        auto result = execution::execute("/usr/bin/zonename");
        if (result.first && result.second != "global") {
            return vm::zone;
        }

        auto arch = facts.get<string_value>(fact::architecture);
        if (!arch) {
            return {};
        }

        string guest_of;

        if (arch->value() == "i86pc") {
            // taken from facter:lib/facter/virtual.rb
            static map<re_adapter, string> virtual_map = {
                {re_adapter("VMware"), string(vm::vmware)},
                {re_adapter("VirtualBox"), string(vm::virtualbox)},
                {re_adapter("Parallels"), string(vm::parallels)},
                {re_adapter("KVM"), string(vm::kvm)},
                {re_adapter("HVM domU"), string(vm::xen_hardware)},
                {re_adapter("oVirt Node"), string(vm::ovirt)}
            };

            execution::each_line("/usr/sbin/prtdiag", [&](string& line) {
                for (auto const& it : virtual_map) {
                    if (re_search(line, it.first)) {
                        guest_of = it.second;
                        return false;
                    }
                }
                return true;
            });
        } else if (arch->value() == "sparc") {
            // Uses hints from
            // http://serverfault.com/questions/153179/how-to-find-out-if-a-solaris-machine-is-virtualized-or-not
            // interface stability is uncommited. Should we use it?
            string role;

            re_adapter domain_role_root("Domain role:.*(root|guest)");
            execution::each_line("/usr/sbin/virtinfo", [&] (string& line) {
                    if (re_search(line, domain_role_root, &role)) {
                        if (role != "root") {
                            guest_of = vm::ldom;
                        }
                        return false;
                    }
                    if (line.find("virtinfo can only be run from the global zone") != string::npos) {
                        guest_of = vm::zone;
                        return false;
                    }
                    // virtinfo can alsy reply:
                    // Virtual machines are not supported
                    return true;
            });
        }
        return guest_of;
    }
}}}  // namespace facter::facts::solaris
