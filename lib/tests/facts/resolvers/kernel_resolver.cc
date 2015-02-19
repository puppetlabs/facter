#include <catch.hpp>
#include <facter/facts/resolvers/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_kernel_resolver : kernel_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_kernel_resolver : kernel_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.name = "foo";
        result.release = "1.2.3-foo";
        result.version = "1.2.3";
        return result;
    }
};

SCENARIO("using the kernel resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_kernel_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_kernel_resolver>());
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 4);
            auto kernel = facts.get<string_value>(fact::kernel);
            REQUIRE(kernel);
            REQUIRE(kernel->value() == "foo");
            auto release = facts.get<string_value>(fact::kernel_release);
            REQUIRE(release);
            REQUIRE(release->value() == "1.2.3-foo");
            auto version = facts.get<string_value>(fact::kernel_version);
            REQUIRE(version);
            REQUIRE(version->value() == "1.2.3");
            auto major = facts.get<string_value>(fact::kernel_major_version);
            REQUIRE(major);
            REQUIRE(major->value() == "1.2");
        }
    }
}
