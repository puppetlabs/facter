#include <facter/facts/resolvers/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    dmi_resolver::dmi_resolver() :
        resolver(
            "desktop management interface",
            {
                fact::bios_vendor,
                fact::bios_version,
                fact::bios_release_date,
                fact::board_asset_tag,
                fact::board_manufacturer,
                fact::board_product_name,
                fact::board_serial_number,
                fact::chassis_asset_tag,
                fact::manufacturer,
                fact::product_name,
                fact::serial_number,
                fact::product_uuid,
                fact::chassis_type,
            })
    {
    }

    string dmi_resolver::to_chassis_description(string const& type)
    {
        if (type.empty()) {
            return {};
        }

        static map<string, string> const descriptions = {
            { "1",  "Other" },
            // 2 is Unknown, which we'll output if it's not in the map anyway
            { "3",  "Desktop" },
            { "4",  "Low Profile Desktop" },
            { "5",  "Pizza Box" },
            { "6",  "Mini Tower" },
            { "7",  "Tower" },
            { "8",  "Portable" },
            { "9",  "Laptop" },
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

    void dmi_resolver::resolve(collection& facts)
    {
        // TODO: replace this with a structured fact
        auto dmi = collect_data(facts);
        if (!dmi.bios_vendor.empty()) {
            facts.add(fact::bios_vendor, make_value<string_value>(move(dmi.bios_vendor)));
        }

        if (!dmi.bios_version.empty()) {
            facts.add(fact::bios_version, make_value<string_value>(move(dmi.bios_version)));
        }

        if (!dmi.bios_release_date.empty()) {
            facts.add(fact::bios_release_date, make_value<string_value>(move(dmi.bios_release_date)));
        }

        if (!dmi.board_asset_tag.empty()) {
            facts.add(fact::board_asset_tag, make_value<string_value>(move(dmi.board_asset_tag)));
        }

        if (!dmi.board_manufacturer.empty()) {
            facts.add(fact::board_manufacturer, make_value<string_value>(move(dmi.board_manufacturer)));
        }

        if (!dmi.board_product_name.empty()) {
            facts.add(fact::board_product_name, make_value<string_value>(move(dmi.board_product_name)));
        }

        if (!dmi.board_serial_number.empty()) {
            facts.add(fact::board_serial_number, make_value<string_value>(move(dmi.board_serial_number)));
        }

        if (!dmi.chassis_asset_tag.empty()) {
            facts.add(fact::chassis_asset_tag, make_value<string_value>(move(dmi.chassis_asset_tag)));
        }

        if (!dmi.manufacturer.empty()) {
            facts.add(fact::manufacturer, make_value<string_value>(move(dmi.manufacturer)));
        }

        if (!dmi.product_name.empty()) {
            facts.add(fact::product_name, make_value<string_value>(move(dmi.product_name)));
        }

        if (!dmi.serial_number.empty()) {
            facts.add(fact::serial_number, make_value<string_value>(move(dmi.serial_number)));
        }

        if (!dmi.product_uuid.empty()) {
            facts.add(fact::product_uuid, make_value<string_value>(move(dmi.product_uuid)));
        }

        if (!dmi.chassis_type.empty()) {
            facts.add(fact::chassis_type, make_value<string_value>(move(dmi.chassis_type)));
        }
    }

}}}  // namespace facter::facts::resolvers
