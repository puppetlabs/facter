#include <catch.hpp>
#include <internal/facts/resolvers/augeas_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_augeas_resolver : augeas_resolver
{
 protected:
    virtual string get_version() override
    {
        return {};
    }
};

struct fixed_augeas_resolver : augeas_resolver
{
 protected:
    virtual string get_version() override
    {
        return "foo";
    }
};

SCENARIO("using the augeas resolver") {
    collection facts;
    WHEN("no version is returned") {
        facts.add(make_shared<empty_augeas_resolver>());
        THEN("the fact is not present") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("an augeas version is returned") {
        facts.add(make_shared<fixed_augeas_resolver>());
        THEN("a structured fact is returned") {
            REQUIRE(facts.size() == 2u);
            auto augeas = facts.get<map_value>(fact::augeas);
            REQUIRE(augeas);
            REQUIRE(augeas->size() == 1u);
            auto version = augeas->get<string_value>("version");
            REQUIRE(version);
            REQUIRE(version->value() == "foo");
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 2u);
            auto augeasversion = facts.get<string_value>(fact::augeasversion);
            REQUIRE(augeasversion);
            REQUIRE(augeasversion->value() == "foo");
        }
    }
}
