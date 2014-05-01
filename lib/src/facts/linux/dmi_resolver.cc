#include <facter/facts/linux/dmi_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include <boost/filesystem.hpp>
#include <map>

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;
namespace bs = boost::system;

LOG_DECLARE_NAMESPACE("facts.osx.dmi");

namespace facter { namespace facts { namespace linux {

    void dmi_resolver::resolve_facts(fact_map& facts)
    {
        static map<string, string> dmi_files {
            { string(fact::bios_vendor), "/sys/class/dmi/id/bios_vendor" },
            { string(fact::bios_version), "/sys/class/dmi/id/bios_version" },
            { string(fact::bios_release_date), "/sys/class/dmi/id/bios_date" },
            { string(fact::board_manufacturer), "/sys/class/dmi/id/board_vendor" },
            { string(fact::board_product_name), "/sys/class/dmi/id/board_name" },
            { string(fact::board_serial_number), "/sys/class/dmi/id/board_serial" },
            { string(fact::manufacturer), "/sys/class/dmi/id/sys_vendor" },
            { string(fact::product_name), "/sys/class/dmi/id/product_name" },
            { string(fact::serial_number), "/sys/class/dmi/id/product_serial" },
            { string(fact::product_uuid), "/sys/class/dmi/id/product_uuid" },
            { string(fact::chassis_type), "/sys/class/dmi/id/chassis_type" },
        };

        for (auto const& kvp : dmi_files) {
            bs::error_code ec;
            if (!is_regular_file(kvp.second, ec)) {
                LOG_DEBUG("%1%: %2%: %3% fact is unavailable.", kvp.second, ec.message(), kvp.first);
                continue;
            }

            string value;
            if (!file::read(kvp.second, value)) {
                LOG_DEBUG("%1%: permission denied: %2% fact is unavailable.", kvp.second, kvp.first);
                continue;
            }

            trim(value);

            // If this is the chassis fact, get the description string
            if (kvp.first == fact::chassis_type) {
                value = get_chassis_description(value);
            }

            facts.add(string(kvp.first), make_value<string_value>(move(value)));
        }
    }

    string dmi_resolver::get_chassis_description(string const& type)
    {
        static map<string, string> descriptions = {
            { "1", "Other" },
            // 2 is Unknown, which we'll output if it's not in the map anyway
            { "3", "Desktop" },
            { "4", "Low Profile Desktop" },
            { "5", "Pizza Box" },
            { "6", "Mini Tower" },
            { "7", "Tower" },
            { "8", "Portable" },
            { "9", "Laptop" },
            { "10", "Notebook" },
            { "11", "Hand Held" },
            { "12", "Docking Station" },
            { "13", "All in One" },
            { "14", "Sub Notebook" },
            { "15", "Space-Saving" },
            { "16", "Lunch Box" },
            { "17", "Main System Chassis" },
            { "18", "Expansion Chassis" },
            { "19", "SubChassis" },
            { "20", "Bus Expansion Chassis" },
            { "21", "Peripheral Chassis" },
            { "22", "Storage Chassis" },
            { "23", "Rack Mount Chassis" },
            { "24", "Sealed-Case PC" },
        };

        auto it = descriptions.find(type);
        if (it != descriptions.end()) {
            return it->second;
        }
        return "Unknown";
    }

}}}  // namespace facter::facts::linux
