#include <gmock/gmock.h>
#include <facter/facts/resolvers/timezone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

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

TEST(facter_facts_resolvers_timezone_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_timezone_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_timezone_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_timezone_resolver>());
    ASSERT_EQ(1u, facts.size());

    auto timezone = facts.get<string_value>(fact::timezone);
    ASSERT_NE(nullptr, timezone);
    ASSERT_EQ("PDT", timezone->value());
}
