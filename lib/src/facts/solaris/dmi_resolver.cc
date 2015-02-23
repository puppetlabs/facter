#include <facter/facts/solaris/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/execution/execution.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace solaris {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        auto arch = facts.get<string_value>(fact::architecture);
        if (arch && arch->value() == "i86pc") {
            re_adapter bios_vendor_re("Vendor: (.+)");
            re_adapter bios_version_re("Version String: (.+)");
            re_adapter bios_release_re("Release Date: (.+)");
            execution::each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_BIOS"}, [&](string& line) {
                if (result.bios_vendor.empty()) {
                    re_search(line, bios_vendor_re, &result.bios_vendor);
                }
                if (result.bios_version.empty()) {
                    re_search(line, bios_version_re, &result.bios_version);
                }
                if (result.bios_release_date.empty()) {
                    re_search(line, bios_release_re, &result.bios_release_date);
                }
                return result.bios_release_date.empty() || result.bios_vendor.empty() || result.bios_version.empty();
            });

            re_adapter manufacturer_re("Manufacturer: (.+)");
            re_adapter uuid_re("UUID: (.+)");
            re_adapter serial_re("Serial Number: (.+)");
            re_adapter product_re("Product: (.+)");
            execution::each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_SYSTEM"}, [&](string& line) {
                if (result.manufacturer.empty()) {
                    re_search(line, manufacturer_re, &result.manufacturer);
                }
                if (result.product_name.empty()) {
                    re_search(line, product_re, &result.product_name);
                }
                if (result.uuid.empty()) {
                    re_search(line, uuid_re, &result.uuid);
                }
                if (result.serial_number.empty()) {
                    re_search(line, serial_re, &result.serial_number);
                }
                return result.manufacturer.empty() || result.product_name.empty() || result.uuid.empty() || result.serial_number.empty();
            });

            re_adapter chassis_type_re("(?:Chassis )?Type: (.+)");
            re_adapter chassis_asset_tag_re("Asset Tag: (.+)");
            execution::each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_CHASSIS"}, [&](string& line) {
                if (result.chassis_type.empty()) {
                    re_search(line, chassis_type_re, &result.chassis_type);
                }
                if (result.chassis_asset_tag.empty()) {
                    re_search(line, chassis_asset_tag_re, &result.chassis_asset_tag);
                }
                return result.chassis_type.empty() || result.chassis_asset_tag.empty();
            });
        } else if (arch && arch->value() == "sparc") {
            re_adapter line_re("System Configuration: (.+) sun\\d.");
            // prtdiag is not implemented in all sparc machines, so we cant get product name this way.
            execution::each_line("/usr/sbin/prtconf", [&](string& line) {
                if (re_search(line, line_re, &result.manufacturer)) {
                    return false;
                }
                return true;
            });
            auto output = execution::execute("/usr/sbin/uname", {"-a"});
            if (output.first) {
                re_search(output.second, ".* sun\\d[vu] sparc SUNW,(.*)", &result.product_name);
            }
        }
        return result;
    }

}}}  // namespace facter::facts::solaris
