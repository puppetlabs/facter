#include <internal/facts/solaris/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace leatherman::util;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace solaris {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        auto isa = facts.get<string_value>(fact::hardware_isa);
        if (isa && isa->value() == "i386") {
            static boost::regex bios_vendor_re("Vendor: (.+)");
            static boost::regex bios_version_re("Version String: (.+)");
            static boost::regex bios_release_re("Release Date: (.+)");
            each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_BIOS"}, [&](string& line) {
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

            static boost::regex manufacturer_re("Manufacturer: (.+)");
            static boost::regex uuid_re("UUID: (.+)");
            static boost::regex serial_re("Serial Number: (.+)");
            static boost::regex product_re("Product: (.+)");
            each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_SYSTEM"}, [&](string& line) {
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

            static boost::regex chassis_type_re("(?:Chassis )?Type: (.+)");
            static boost::regex chassis_asset_tag_re("Asset Tag: (.+)");
            each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_CHASSIS"}, [&](string& line) {
                if (result.chassis_type.empty()) {
                    re_search(line, chassis_type_re, &result.chassis_type);
                }
                if (result.chassis_asset_tag.empty()) {
                    re_search(line, chassis_asset_tag_re, &result.chassis_asset_tag);
                }
                return result.chassis_type.empty() || result.chassis_asset_tag.empty();
            });
        } else if (isa && isa->value() == "sparc") {
            static boost::regex manufacturer_re("^System Configuration: (.+) sun\\d.$");
            static boost::regex product_name_re("^SUNW,(.*)$");
            // prtdiag is not implemented in all sparc machines, so we cant get product name this way.
            each_line("/usr/sbin/prtconf", [&](string& line) {
                if (result.manufacturer.empty()) {
                    re_search(line, manufacturer_re, &result.manufacturer);
                }
                if (result.product_name.empty()) {
                    re_search(line, product_name_re, &result.product_name);
                }
                return result.manufacturer.empty() || result.product_name.empty();
            });
            // Manufacturer appears to have two spaces before and after it, but we don't want to rely on that formatting.
            boost::trim(result.manufacturer);

            auto exec = execute("/usr/sbin/sneep");
            if (exec.success) {
                result.serial_number = exec.output;
            }
        }
        return result;
    }

}}}  // namespace facter::facts::solaris
