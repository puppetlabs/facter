#include <facter/facts/solaris/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("facts.solaris.dmi");

namespace facter { namespace facts { namespace solaris {

    void dmi_resolver::resolve_facts(collection& facts)
    {
        // We only support getting the product name on solaris
        resolve_bios(facts);
        resolve_manufacturer(facts);
    }

    void dmi_resolver::resolve_bios(collection& facts)
    {
        auto arch = facts.get<string_value>(fact::architecture);
        if (!arch) {
            return;
        }
        if (arch->value() == "i86pc") {
            string bios_vendor;
            string bios_version;
            string bios_release;
            re_adapter bios_vendor_re("Vendor: (.+)");
            re_adapter bios_version_re("Version String: (.+)");
            re_adapter bios_release_re("Release Date: (.+)");
            execution::each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_BIOS"}, [&](string& line) {
                if (bios_vendor.empty()) {
                    re_search(line, bios_vendor_re, &bios_vendor);
                }
                if (bios_version.empty()) {
                    re_search(line, bios_version_re, &bios_version);
                }
                if (bios_release.empty()) {
                    re_search(line, bios_release_re, &bios_release);
                }
                return bios_release.empty() || bios_version.empty() || bios_release.empty();
            });
            if (!bios_version.empty()) {
                facts.add(fact::bios_version, make_value<string_value>(move(bios_version)));
            }
            if (!bios_release.empty()) {
                facts.add(fact::bios_release_date, make_value<string_value>(move(bios_release)));
            }
            if (!bios_vendor.empty()) {
                facts.add(fact::bios_vendor, make_value<string_value>(move(bios_vendor)));
            }
        } else if (arch->value() == "sparc") {
            // not impl
        }
    }

    void dmi_resolver::resolve_manufacturer(collection& facts)
    {
        auto arch = facts.get<string_value>(fact::architecture);
        if (!arch) {
            return;
        }
        if (arch->value() == "i86pc") {
            string manufacturer;
            string product;
            string uuid;
            string serial;
            // UUID:, Serial Number:, Version:, Family:
            re_adapter manufacturer_re("Manufacturer: (.+)");
            re_adapter uuid_re("UUID: (.+)");
            re_adapter serial_re("Serial Number: (.+)");
            re_adapter product_re("Product: (.+)");
            execution::each_line("/usr/sbin/smbios", {"-t", "SMB_TYPE_SYSTEM"}, [&](string& line) {
                if (manufacturer.empty()) {
                    re_search(line, manufacturer_re, &manufacturer);
                }
                if (product.empty()) {
                    re_search(line, product_re, &product);
                }
                if (uuid.empty()) {
                    re_search(line, uuid_re, &uuid);
                }
                if (serial.empty()) {
                    re_search(line, serial_re, &serial);
                }
                return manufacturer.empty() || product.empty() || uuid.empty() || serial.empty();
            });
            if (!manufacturer.empty()) {
                facts.add(fact::manufacturer, make_value<string_value>(move(manufacturer)));
            }
            if (!product.empty()) {
                facts.add(fact::product_name, make_value<string_value>(move(product)));
            }
            if (!serial.empty()) {
                facts.add(fact::serial_number, make_value<string_value>(move(serial)));
            }
            if (!uuid.empty()) {
                facts.add(fact::product_uuid, make_value<string_value>(move(uuid)));
            }

        } else if (arch->value() == "sparc") {
            string manufacturer;
            string product;
            re_adapter line_re("System Configuration: (.+) sun\\d.");
            // prtdiag is not implemented in all sparc machines, so we cant get
            // product name this way.
            execution::each_line("/usr/sbin/prtconf", [&](string& line) {
                if (re_search(line, line_re, &manufacturer)) {
                    facts.add(fact::manufacturer, make_value<string_value>(move(manufacturer)));
                    return false;
                }
                return true;
            });
            auto line = execution::execute("/usr/sbin/uname", {"-a"});
            if (line.first && re_search(line.second, ".* sun\\d[vu] sparc SUNW,(.*)", &product)) {
                facts.add(fact::product_name, make_value<string_value>(move(product)));
            }
        }
    }
}}}  // namespace facter::facts::solaris
