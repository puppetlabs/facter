#include <facter/facts/osx/virtualization_resolver.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/virtual_machine.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace osx {

    string virtualization_resolver::get_hypervisor(fact_map& facts)
    {
        // Check for VMWare
        auto machine_model = facts.get<string_value>(fact::sp_machine_model);
        if (machine_model) {
            if (starts_with(machine_model->value(), "VMware")) {
                return vm::vmware;
            }
        }

        // Check for VirtualBox
        auto boot_rom_version = facts.get<string_value>(fact::sp_boot_rom_version);
        if (boot_rom_version) {
            if (boot_rom_version->value() == "VirtualBox") {
                return vm::virtualbox;
            }
        }

        // Check for Parallels
        string value;
        execution::each_line("/usr/sbin/system_profiler", { "SPEthernetDataType" }, [&](string& line) {
            if (trim(line) == "Subsystem Vendor ID: 0x1ab8") {
                value = vm::parallels;
                return false;
            }
            return true;
        });
        return value;
    }

}}}  // namespace facter::facts::osx
