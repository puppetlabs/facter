#include <catch.hpp>
#include <facter/facts/resolvers/identity_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_identity_resolver : identity_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_identity_resolver : identity_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.group_id = 123;
        result.group_name = "foo";
        result.user_id = 456;
        result.user_name = "bar";
        return result;
    }
};

SCENARIO("using the identity resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_identity_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_identity_resolver>());
        THEN("a structured fact is added") {
            auto identity = facts.get<map_value>(fact::identity);
            REQUIRE(identity);
            REQUIRE(identity->size() == 4);

            auto name = identity->get<string_value>("group");
            REQUIRE(name);
            REQUIRE(name->value() == "foo");

            auto id = identity->get<integer_value>("gid");
            REQUIRE(id);
            REQUIRE(id->value() == 123);

            name = identity->get<string_value>("user");
            REQUIRE(name);
            REQUIRE(name->value() == "bar");

            id = identity->get<integer_value>("uid");
            REQUIRE(id);
            REQUIRE(id->value() == 456);
        }
        THEN("flat facts are added") {
            auto name = facts.get<string_value>(fact::gid);
            REQUIRE(name);
            REQUIRE(name->value() == "foo");

            name = facts.get<string_value>(fact::id);
            REQUIRE(name);
            REQUIRE(name->value() == "bar");
        }
    }
}
