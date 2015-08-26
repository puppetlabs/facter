#include <catch.hpp>
#include <internal/facts/resolvers/uptime_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct test_less_than_day_resolver : uptime_resolver
{
 protected:
    virtual int64_t get_uptime(collection& facts) override
    {
        // 13 hours, 35 minutes, 6 seconds
        return (13 * 60 * 60) + (35 * 60) + 6;
    }
};

struct test_one_day_resolver : uptime_resolver
{
 protected:
    virtual int64_t get_uptime(collection& facts) override
    {
        // 1 day, 2 hours, 12 minutes, 22 seconds
        return (1 * 24 * 60 * 60) + (2 * 60 * 60) + (12 * 60) + 22;
    }
};

struct test_more_than_day_resolver : uptime_resolver
{
 protected:
    virtual int64_t get_uptime(collection& facts) override
    {
        // 3 day, 4 hours, 19 minutes, 45 seconds
        return (3 * 24 * 60 * 60) + (4 * 60 * 60) + (19 * 60) + 45;
    }
};

SCENARIO("using the uptime resolver") {
    collection_fixture facts;
    WHEN("the uptime is less than one day") {
        facts.add(make_shared<test_less_than_day_resolver>());
        THEN("a structured fact with 'hours' uptime is added") {
            auto system_uptime = facts.get<map_value>(fact::system_uptime);
            REQUIRE(system_uptime);
            REQUIRE(system_uptime->size() == 4u);
            auto time = system_uptime->get<integer_value>("seconds");
            REQUIRE(time);
            REQUIRE(time->value() == 48906);
            time = system_uptime->get<integer_value>("hours");
            REQUIRE(time);
            REQUIRE(time->value() == 13);
            time = system_uptime->get<integer_value>("days");
            REQUIRE(time);
            REQUIRE(time->value() == 0);
            auto uptime = system_uptime->get<string_value>("uptime");
            REQUIRE(uptime);
            REQUIRE(uptime->value() == "13:35 hours");
        }
        THEN("flat facts with 'hours' uptime is added") {
            REQUIRE(facts.size() == 5u);
            auto time = facts.get<integer_value>(fact::uptime_seconds);
            REQUIRE(time);
            REQUIRE(time->value() == 48906);
            time = facts.get<integer_value>(fact::uptime_hours);
            REQUIRE(time);
            REQUIRE(time->value() == 13);
            time = facts.get<integer_value>(fact::uptime_days);
            REQUIRE(time);
            REQUIRE(time->value() == 0);
            auto uptime = facts.get<string_value>(fact::uptime);
            REQUIRE(uptime);
            REQUIRE(uptime->value() == "13:35 hours");
        }
    }
    WHEN("the uptime is one day") {
        facts.add(make_shared<test_one_day_resolver>());
        THEN("a structured fact with '1 day' uptime is added") {
            auto system_uptime = facts.get<map_value>(fact::system_uptime);
            REQUIRE(system_uptime);
            REQUIRE(system_uptime->size() == 4u);
            auto time = system_uptime->get<integer_value>("seconds");
            REQUIRE(time);
            REQUIRE(time->value() == 94342);
            time = system_uptime->get<integer_value>("hours");
            REQUIRE(time);
            REQUIRE(time->value() == 26);
            time = system_uptime->get<integer_value>("days");
            REQUIRE(time);
            REQUIRE(time->value() == 1);
            auto uptime = system_uptime->get<string_value>("uptime");
            REQUIRE(uptime);
            REQUIRE(uptime->value() == "1 day");
        }
        THEN("flat facts with '1 day' uptime is added") {
            REQUIRE(facts.size() == 5u);
            auto time = facts.get<integer_value>(fact::uptime_seconds);
            REQUIRE(time);
            REQUIRE(time->value() == 94342);
            time = facts.get<integer_value>(fact::uptime_hours);
            REQUIRE(time);
            REQUIRE(time->value() == 26);
            time = facts.get<integer_value>(fact::uptime_days);
            REQUIRE(time);
            REQUIRE(time->value() == 1);
            auto uptime = facts.get<string_value>(fact::uptime);
            REQUIRE(uptime);
            REQUIRE(uptime->value() == "1 day");
        }
    }
    WHEN("the uptime is more than one day") {
        facts.add(make_shared<test_more_than_day_resolver>());
        THEN("a structured fact with 'x days' uptime is added") {
            auto system_uptime = facts.get<map_value>(fact::system_uptime);
            REQUIRE(system_uptime);
            REQUIRE(system_uptime->size() == 4u);
            auto time = system_uptime->get<integer_value>("seconds");
            REQUIRE(time);
            REQUIRE(time->value() == 274785);
            time = system_uptime->get<integer_value>("hours");
            REQUIRE(time);
            REQUIRE(time->value() == 76);
            time = system_uptime->get<integer_value>("days");
            REQUIRE(time);
            REQUIRE(time->value() == 3);
            auto uptime = system_uptime->get<string_value>("uptime");
            REQUIRE(uptime);
            REQUIRE(uptime->value() == "3 days");
        }
        THEN("flat facts with 'x days' uptime is added") {
            REQUIRE(facts.size() == 5u);
            auto time = facts.get<integer_value>(fact::uptime_seconds);
            REQUIRE(time);
            REQUIRE(time->value() == 274785);
            time = facts.get<integer_value>(fact::uptime_hours);
            REQUIRE(time);
            REQUIRE(time->value() == 76);
            time = facts.get<integer_value>(fact::uptime_days);
            REQUIRE(time);
            REQUIRE(time->value() == 3);
            auto uptime = facts.get<string_value>(fact::uptime);
            REQUIRE(uptime);
            REQUIRE(uptime->value() == "3 days");
        }
    }
}
