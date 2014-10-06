#include <gmock/gmock.h>
#include <facter/facts/resolvers/identity_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

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

TEST(facter_facts_resolvers_identity_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_identity_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_identity_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_identity_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto group = facts.get<string_value>(fact::gid);
    ASSERT_NE(nullptr, group);
    ASSERT_EQ("foo", group->value());

    auto user = facts.get<string_value>(fact::id);
    ASSERT_NE(nullptr, user);
    ASSERT_EQ("bar", user->value());
}
