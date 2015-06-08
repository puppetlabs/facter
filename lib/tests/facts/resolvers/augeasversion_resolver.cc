#include <catch.hpp>
#include <internal/facts/resolvers/augeasversion_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_augeasversion_resolver : augeasversion_resolver
{
 protected:
    virtual string get_version() override
    {
        return {};
    }
};

struct fixed_augeasversion_resolver : augeasversion_resolver
{
 protected:
    virtual string get_version() override
    {
        return "foo";
    }
};

SCENARIO("using the augeasversion resolver") {
    collection facts;
    WHEN("no version is returned") {
        facts.add(make_shared<empty_augeasversion_resolver>());
        THEN("the fact is not present") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("a version string is returned") {
        facts.add(make_shared<fixed_augeasversion_resolver>());
        THEN("the augeasversion fact exists") {
            REQUIRE(facts.size() == 1u);
            auto augeasversion = facts.get<string_value>(fact::augeasversion);
            REQUIRE(augeasversion);
            REQUIRE(augeasversion->value() == "foo");
        }
    }
}
