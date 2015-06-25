#include <catch.hpp>
#include <internal/facts/resolvers/timezone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_timezone_resolver : timezone_resolver
{
 protected:
    virtual string get_timezone() override
    {
        return {};
    }
};

struct test_timezone_resolver : timezone_resolver
{
 protected:
    virtual string get_timezone() override
    {
        return "PDT";
    }
};

SCENARIO("using the timezone resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_timezone_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_timezone_resolver>());
        THEN("a flat fact is added") {
            REQUIRE(facts.size() == 1u);
            auto timezone = facts.get<string_value>(fact::timezone);
            REQUIRE(timezone);
            REQUIRE(timezone->value() == "PDT");
        }
    }
}
