#include <internal/facts/osx/virtualization_resolver.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;

namespace facter { namespace facts { namespace osx {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // Check for VMWare
        auto machine_model = facts.get<string_value>(fact::sp_machine_model);
        if (machine_model) {
            if (boost::starts_with(machine_model->value(), "VMware")) {
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
            boost::trim(line);
            if (line == "Subsystem Vendor ID: 0x1ab8") {
                value = vm::parallels;
                return false;
            }
            return true;
        });
        return value;
    }

}}}  // namespace facter::facts::osx
