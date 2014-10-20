#include <gmock/gmock.h>
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
        result.product_uuid = fact::product_uuid;
        result.chassis_type = fact::chassis_type;
        return result;
    }
};

TEST(facter_facts_resolvers_dmi_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_dmi_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_dmi_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_dmi_resolver>());
    ASSERT_EQ(14u, facts.size());

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
        fact::product_uuid,
        fact::chassis_type,
    };

    for (auto const& name : names) {
        auto fact = facts.get<string_value>(name);
        ASSERT_NE(nullptr, fact);
        ASSERT_EQ(name, fact->value());
    }

    auto dmi = facts.get<map_value>(fact::dmi);
    ASSERT_NE(nullptr, dmi);
    ASSERT_EQ(5u, dmi->size());

    auto bios = dmi->get<map_value>("bios");
    ASSERT_NE(nullptr, bios);
    ASSERT_EQ(3u, bios->size());

    auto value = bios->get<string_value>("release_date");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::bios_release_date), value->value());

    value = bios->get<string_value>("vendor");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::bios_vendor), value->value());

    value = bios->get<string_value>("version");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::bios_version), value->value());

    auto board = dmi->get<map_value>("board");
    ASSERT_NE(nullptr, board);
    ASSERT_EQ(4u, board->size());

    value = board->get<string_value>("asset_tag");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::board_asset_tag), value->value());

    value = board->get<string_value>("manufacturer");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::board_manufacturer), value->value());

    value = board->get<string_value>("product");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::board_product_name), value->value());

    value = board->get<string_value>("serial_number");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::board_serial_number), value->value());

    auto chassis = dmi->get<map_value>("chassis");
    ASSERT_NE(nullptr, chassis);
    ASSERT_EQ(2u, chassis->size());

    value = chassis->get<string_value>("asset_tag");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::chassis_asset_tag), value->value());

    value = chassis->get<string_value>("type");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::chassis_type), value->value());

    value = dmi->get<string_value>("manufacturer");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::manufacturer), value->value());

    auto product = dmi->get<map_value>("product");
    ASSERT_NE(nullptr, product);
    ASSERT_EQ(3u, product->size());

    value = product->get<string_value>("name");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::product_name), value->value());

    value = product->get<string_value>("serial_number");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::serial_number), value->value());

    value = product->get<string_value>("uuid");
    ASSERT_NE(nullptr, value);
    ASSERT_EQ(string(fact::product_uuid), value->value());
}
