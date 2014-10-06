#include <gmock/gmock.h>
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

TEST(facter_facts_resolvers_kernel_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_kernel_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_kernel_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_kernel_resolver>());
    ASSERT_EQ(4u, facts.size());

    auto kernel = facts.get<string_value>(fact::kernel);
    ASSERT_NE(nullptr, kernel);
    ASSERT_EQ("foo", kernel->value());

    auto release = facts.get<string_value>(fact::kernel_release);
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("1.2.3-foo", release->value());

    auto version = facts.get<string_value>(fact::kernel_version);
    ASSERT_NE(nullptr, version);
    ASSERT_EQ("1.2.3", version->value());

    auto major = facts.get<string_value>(fact::kernel_major_version);
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("1.2", major->value());
}
