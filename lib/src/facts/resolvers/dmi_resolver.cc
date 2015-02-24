#include <facter/facts/resolvers/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    dmi_resolver::dmi_resolver() :
        resolver(
            "desktop management interface",
            {
                fact::dmi,
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
                fact::uuid,
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
        auto data = collect_data(facts);
        auto dmi = make_value<map_value>();

        auto bios = make_value<map_value>();
        if (!data.bios_vendor.empty()) {
            facts.add(fact::bios_vendor, make_value<string_value>(data.bios_vendor, true));
            bios->add("vendor", make_value<string_value>(move(data.bios_vendor)));
        }
        if (!data.bios_version.empty()) {
            facts.add(fact::bios_version, make_value<string_value>(data.bios_version, true));
            bios->add("version", make_value<string_value>(move(data.bios_version)));
        }
        if (!data.bios_release_date.empty()) {
            facts.add(fact::bios_release_date, make_value<string_value>(data.bios_release_date, true));
            bios->add("release_date", make_value<string_value>(move(data.bios_release_date)));
        }

        auto board = make_value<map_value>();
        if (!data.board_asset_tag.empty()) {
            facts.add(fact::board_asset_tag, make_value<string_value>(data.board_asset_tag, true));
            board->add("asset_tag", make_value<string_value>(move(data.board_asset_tag)));
        }
        if (!data.board_manufacturer.empty()) {
            facts.add(fact::board_manufacturer, make_value<string_value>(data.board_manufacturer, true));
            board->add("manufacturer", make_value<string_value>(move(data.board_manufacturer)));
        }
        if (!data.board_product_name.empty()) {
            facts.add(fact::board_product_name, make_value<string_value>(data.board_product_name, true));
            board->add("product", make_value<string_value>(move(data.board_product_name)));
        }
        if (!data.board_serial_number.empty()) {
            facts.add(fact::board_serial_number, make_value<string_value>(data.board_serial_number, true));
            board->add("serial_number", make_value<string_value>(move(data.board_serial_number)));
        }

        auto product = make_value<map_value>();
        if (!data.product_name.empty()) {
            facts.add(fact::product_name, make_value<string_value>(data.product_name, true));
            product->add("name", make_value<string_value>(move(data.product_name)));
        }
        if (!data.serial_number.empty()) {
            facts.add(fact::serial_number, make_value<string_value>(data.serial_number, true));
            product->add("serial_number", make_value<string_value>(move(data.serial_number)));
        }
        if (!data.uuid.empty()) {
            facts.add(fact::uuid, make_value<string_value>(data.uuid, true));
            product->add("uuid", make_value<string_value>(move(data.uuid)));
        }

        auto chassis = make_value<map_value>();
        if (!data.chassis_asset_tag.empty()) {
            facts.add(fact::chassis_asset_tag, make_value<string_value>(data.chassis_asset_tag, true));
            chassis->add("asset_tag", make_value<string_value>(move(data.chassis_asset_tag)));
        }
        if (!data.chassis_type.empty()) {
            facts.add(fact::chassis_type, make_value<string_value>(data.chassis_type, true));
            chassis->add("type", make_value<string_value>(move(data.chassis_type)));
        }

        if (!data.manufacturer.empty()) {
            facts.add(fact::manufacturer, make_value<string_value>(data.manufacturer, true));
            dmi->add("manufacturer", make_value<string_value>(move(data.manufacturer)));
        }

        if (!bios->empty()) {
            dmi->add("bios", move(bios));
        }

        if (!board->empty()) {
            dmi->add("board", move(board));
        }

        if (!product->empty()) {
            dmi->add("product", move(product));
        }

        if (!chassis->empty()) {
            dmi->add("chassis", move(chassis));
        }

        if (!dmi->empty()) {
            facts.add(fact::dmi, move(dmi));
        }
    }

}}}  // namespace facter::facts::resolvers
