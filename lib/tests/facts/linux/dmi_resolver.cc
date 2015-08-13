#include <catch.hpp>
#include <facter/util/string.hpp>
#include <internal/facts/linux/dmi_resolver.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::util;
using namespace facter::testing;

struct dmi_output : facter::facts::linux::dmi_resolver
{
    explicit dmi_output(string const& output)
    {
        data result;
        int dmi_type = -1;

        each_line(output, [&](string& line) {
            parse_dmidecode_output(result, line, dmi_type);
            return true;
        });

        bios_vendor = std::move(result.bios_vendor);
        bios_version = std::move(result.bios_version);
        bios_release_date = std::move(result.bios_release_date);
        board_asset_tag = std::move(result.board_asset_tag);
        board_manufacturer = std::move(result.board_manufacturer);
        board_product_name = std::move(result.board_product_name);
        board_serial_number = std::move(result.board_serial_number);
        chassis_asset_tag = std::move(result.chassis_asset_tag);
        manufacturer = std::move(result.manufacturer);
        product_name = std::move(result.product_name);
        serial_number = std::move(result.serial_number);
        uuid = std::move(result.uuid);
        chassis_type = std::move(result.chassis_type);
    }

    string bios_vendor;
    string bios_version;
    string bios_release_date;
    string board_asset_tag;
    string board_manufacturer;
    string board_product_name;
    string board_serial_number;
    string chassis_asset_tag;
    string manufacturer;
    string product_name;
    string serial_number;
    string uuid;
    string chassis_type;
};

SCENARIO("parsing empty dmidecode output") {
    string contents;
    REQUIRE(load_fixture("facts/linux/dmidecode/none.txt", contents));
    dmi_output output(contents);

    THEN("all fields should be empty") {
        REQUIRE(output.bios_vendor.empty());
        REQUIRE(output.bios_version.empty());
        REQUIRE(output.bios_release_date.empty());
        REQUIRE(output.board_asset_tag.empty());
        REQUIRE(output.board_manufacturer.empty());
        REQUIRE(output.board_product_name.empty());
        REQUIRE(output.board_serial_number.empty());
        REQUIRE(output.chassis_asset_tag.empty());
        REQUIRE(output.manufacturer.empty());
        REQUIRE(output.serial_number.empty());
        REQUIRE(output.product_name.empty());
        REQUIRE(output.uuid.empty());
        REQUIRE(output.chassis_type.empty());
    }
}

SCENARIO("parsing full dmidecode output") {
    string contents;
    REQUIRE(load_fixture("facts/linux/dmidecode/full.txt", contents));
    dmi_output output(contents);

    THEN("all fields should be populated") {
        REQUIRE(output.bios_vendor == "innotek GmbH");
        REQUIRE(output.bios_version == "VirtualBox");
        REQUIRE(output.bios_release_date == "12/01/2006");
        REQUIRE(output.board_asset_tag == "Not Specified");
        REQUIRE(output.board_manufacturer == "Oracle Corporation");
        REQUIRE(output.board_product_name == "VirtualBox");
        REQUIRE(output.board_serial_number == "0");
        REQUIRE(output.chassis_asset_tag == "Not Specified");
        REQUIRE(output.manufacturer == "innotek GmbH");
        REQUIRE(output.serial_number == "0");
        REQUIRE(output.product_name == "VirtualBox");
        REQUIRE(output.uuid == "735AE71B-8655-4AE2-9CA9-172C1BBEDAB5");
        REQUIRE(output.chassis_type == "Other");
    }
}

SCENARIO("parsing full dmidecode output in an alternative format") {
    string contents;
    REQUIRE(load_fixture("facts/linux/dmidecode/full_alternative.txt", contents));
    dmi_output output(contents);

    THEN("all fields should be populated") {
        REQUIRE(output.bios_vendor == "innotek GmbH");
        REQUIRE(output.bios_version == "VirtualBox");
        REQUIRE(output.bios_release_date == "12/01/2006");
        REQUIRE(output.board_asset_tag == "Not Specified");
        REQUIRE(output.board_manufacturer == "Oracle Corporation");
        REQUIRE(output.board_product_name == "VirtualBox");
        REQUIRE(output.board_serial_number == "0");
        REQUIRE(output.chassis_asset_tag == "Not Specified");
        REQUIRE(output.manufacturer == "innotek GmbH");
        REQUIRE(output.serial_number == "0");
        REQUIRE(output.product_name == "VirtualBox");
        REQUIRE(output.uuid == "735AE71B-8655-4AE2-9CA9-172C1BBEDAB5");
        REQUIRE(output.chassis_type == "Other");
    }
}