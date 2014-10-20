#include <gmock/gmock.h>
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
    ASSERT_EQ(3u, facts.size());

    auto name = facts.get<string_value>(fact::gid);
    ASSERT_NE(nullptr, name);
    ASSERT_EQ("foo", name->value());

    name = facts.get<string_value>(fact::id);
    ASSERT_NE(nullptr, name);
    ASSERT_EQ("bar", name->value());

    auto identity = facts.get<map_value>(fact::identity);
    ASSERT_NE(nullptr, identity);
    ASSERT_EQ(4u, identity->size());

    name = identity->get<string_value>("group");
    ASSERT_NE(nullptr, name);
    ASSERT_EQ("foo", name->value());

    auto id = identity->get<integer_value>("gid");
    ASSERT_NE(nullptr, id);
    ASSERT_EQ(123, id->value());

    name = identity->get<string_value>("user");
    ASSERT_NE(nullptr, name);
    ASSERT_EQ("bar", name->value());

    id = identity->get<integer_value>("uid");
    ASSERT_NE(nullptr, id);
    ASSERT_EQ(456, id->value());
}
