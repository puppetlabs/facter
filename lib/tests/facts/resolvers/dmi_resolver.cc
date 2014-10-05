#include <gmock/gmock.h>
#include <facter/facts/resolvers/dmi_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

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
    ASSERT_EQ(13u, facts.size());

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
}
