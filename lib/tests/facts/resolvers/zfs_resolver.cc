#include <catch.hpp>
#include <internal/facts/resolvers/zfs_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_zfs_resolver : zfs_resolver
{
 protected:
    virtual string zfs_command()
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        return result;
    }
};

struct test_zfs_resolver : zfs_resolver
{
 protected:
    virtual string zfs_command()
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        result.version = "1";
        result.features = { "1", "2", "3" };
        return result;
    }
};

SCENARIO("using the ZFS resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_zfs_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_zfs_resolver>());
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 2u);
            auto value = facts.get<string_value>(fact::zfs_version);
            REQUIRE(value);
            REQUIRE(value->value() == "1");
            value = facts.get<string_value>(fact::zfs_featurenumbers);
            REQUIRE(value);
            REQUIRE(value->value() == "1,2,3");
        }
    }
}
