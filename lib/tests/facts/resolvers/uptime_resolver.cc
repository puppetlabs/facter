#include <gmock/gmock.h>
#include <facter/facts/resolvers/uptime_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct test_less_than_day_resolver : uptime_resolver
{
 protected:
    virtual int64_t get_uptime() override
    {
        // 13 hours, 35 minutes, 6 seconds
        return (13 * 60 * 60) + (35 * 60) + 6;
    }
};

struct test_one_day_resolver : uptime_resolver
{
 protected:
    virtual int64_t get_uptime() override
    {
        // 1 day, 2 hours, 12 minutes, 22 seconds
        return (1 * 24 * 60 * 60) + (2 * 60 * 60) + (12 * 60) + 22;
    }
};

struct test_more_than_day_resolver : uptime_resolver
{
 protected:
    virtual int64_t get_uptime() override
    {
        // 3 day, 4 hours, 19 minutes, 45 seconds
        return (3 * 24 * 60 * 60) + (4 * 60 * 60) + (19 * 60) + 45;
    }
};

TEST(facter_facts_resolvers_uptime_resolver, less_than_day)
{
    collection facts;
    facts.add(make_shared<test_less_than_day_resolver>());
    ASSERT_EQ(5u, facts.size());

    auto time = facts.get<integer_value>(fact::uptime_seconds);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(48906, time->value());

    time = facts.get<integer_value>(fact::uptime_hours);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(13, time->value());

    time = facts.get<integer_value>(fact::uptime_days);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(0, time->value());

    auto uptime = facts.get<string_value>(fact::uptime);
    ASSERT_NE(nullptr, uptime);
    ASSERT_EQ("13:35 hours", uptime->value());

    auto system_uptime = facts.get<map_value>(fact::system_uptime);
    ASSERT_NE(nullptr, system_uptime);
    ASSERT_EQ(4u, system_uptime->size());

    time = system_uptime->get<integer_value>("seconds");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(48906, time->value());

    time = system_uptime->get<integer_value>("hours");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(13, time->value());

    time = system_uptime->get<integer_value>("days");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(0, time->value());

    uptime = system_uptime->get<string_value>("uptime");
    ASSERT_NE(nullptr, uptime);
    ASSERT_EQ("13:35 hours", uptime->value());
}

TEST(facter_facts_resolvers_uptime_resolver, one_day)
{
    collection facts;
    facts.add(make_shared<test_one_day_resolver>());
    ASSERT_EQ(5u, facts.size());

    auto time = facts.get<integer_value>(fact::uptime_seconds);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(94342, time->value());

    time = facts.get<integer_value>(fact::uptime_hours);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(26, time->value());

    time = facts.get<integer_value>(fact::uptime_days);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(1, time->value());

    auto uptime = facts.get<string_value>(fact::uptime);
    ASSERT_NE(nullptr, uptime);
    ASSERT_EQ("1 day", uptime->value());

    auto system_uptime = facts.get<map_value>(fact::system_uptime);
    ASSERT_NE(nullptr, system_uptime);
    ASSERT_EQ(4u, system_uptime->size());

    time = system_uptime->get<integer_value>("seconds");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(94342, time->value());

    time = system_uptime->get<integer_value>("hours");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(26, time->value());

    time = system_uptime->get<integer_value>("days");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(1, time->value());

    uptime = system_uptime->get<string_value>("uptime");
    ASSERT_NE(nullptr, uptime);
    ASSERT_EQ("1 day", uptime->value());
}

TEST(facter_facts_resolvers_uptime_resolver, more_than_day)
{
    collection facts;
    facts.add(make_shared<test_more_than_day_resolver>());
    ASSERT_EQ(5u, facts.size());

    auto time = facts.get<integer_value>(fact::uptime_seconds);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(274785, time->value());

    time = facts.get<integer_value>(fact::uptime_hours);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(76, time->value());

    time = facts.get<integer_value>(fact::uptime_days);
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(3, time->value());

    auto uptime = facts.get<string_value>(fact::uptime);
    ASSERT_NE(nullptr, uptime);
    ASSERT_EQ("3 days", uptime->value());

    auto system_uptime = facts.get<map_value>(fact::system_uptime);
    ASSERT_NE(nullptr, system_uptime);
    ASSERT_EQ(4u, system_uptime->size());

    time = system_uptime->get<integer_value>("seconds");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(274785, time->value());

    time = system_uptime->get<integer_value>("hours");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(76, time->value());

    time = system_uptime->get<integer_value>("days");
    ASSERT_NE(nullptr, time);
    ASSERT_EQ(3, time->value());

    uptime = system_uptime->get<string_value>("uptime");
    ASSERT_NE(nullptr, uptime);
    ASSERT_EQ("3 days", uptime->value());
}
