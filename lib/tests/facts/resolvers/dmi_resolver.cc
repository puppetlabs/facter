#include <catch.hpp>
#include <facter/facts/resolvers/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_dmi_resolver : dmi_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_dmi_resolver : dmi_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.bios_vendor = fact::bios_vendor;
        result.bios_version = fact::bios_version;
        result.bios_release_date = fact::bios_release_date;
        result.board_asset_tag = fact::board_asset_tag;
        result.board_manufacturer = fact::board_manufacturer;
        result.board_product_name = fact::board_product_name;
        result.board_serial_number = fact::board_serial_number;
        result.chassis_asset_tag = fact::chassis_asset_tag;
        result.manufacturer = fact::manufacturer;
        result.product_name = fact::product_name;
        result.serial_number = fact::serial_number;
        result.uuid = fact::uuid;
        result.chassis_type = fact::chassis_type;
        return result;
    }
};

SCENARIO("using the DMI resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_dmi_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_dmi_resolver>());
        THEN("a structured fact is added") {
            auto dmi = facts.get<map_value>(fact::dmi);
            REQUIRE(dmi);
            REQUIRE(dmi->size() == 5);

            auto bios = dmi->get<map_value>("bios");
            REQUIRE(bios);
            REQUIRE(bios->size() == 3);

            auto value = bios->get<string_value>("release_date");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::bios_release_date));

            value = bios->get<string_value>("vendor");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::bios_vendor));

            value = bios->get<string_value>("version");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::bios_version));

            auto board = dmi->get<map_value>("board");
            REQUIRE(board);
            REQUIRE(board->size() == 4);

            value = board->get<string_value>("asset_tag");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::board_asset_tag));

            value = board->get<string_value>("manufacturer");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::board_manufacturer));

            value = board->get<string_value>("product");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::board_product_name));

            value = board->get<string_value>("serial_number");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::board_serial_number));

            auto chassis = dmi->get<map_value>("chassis");
            REQUIRE(chassis);
            REQUIRE(chassis->size() == 2);

            value = chassis->get<string_value>("asset_tag");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::chassis_asset_tag));

            value = chassis->get<string_value>("type");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::chassis_type));

            value = dmi->get<string_value>("manufacturer");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::manufacturer));

            auto product = dmi->get<map_value>("product");
            REQUIRE(product);
            REQUIRE(product->size() == 3);

            value = product->get<string_value>("name");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::product_name));

            value = product->get<string_value>("serial_number");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::serial_number));

            value = product->get<string_value>("uuid");
            REQUIRE(value);
            REQUIRE(value->value() == string(fact::uuid));
        }
        THEN("flat facts are added") {
            static vector<string> const names = {
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
            };
            for (auto const& name : names) {
                auto fact = facts.get<string_value>(name);
                REQUIRE(fact);
                REQUIRE(fact->value() == name);
            }
        }
    }
}
