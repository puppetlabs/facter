#include <gmock/gmock.h>
#include <facter/facts/resolvers/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_processor_resolver : processor_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_processor_resolver : processor_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.isa = "isa";
        result.logical_count = 4;
        result.physical_count = 2;
        result.models = {
            "processor1",
            "processor2",
            "processor3",
            "processor4"
        };
        result.speed = 10 * 1000 * 1000 * 1000ull;
        return result;
    }
};

TEST(facter_facts_resolvers_processor_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_processor_resolver>());
    ASSERT_EQ(3u, facts.size());

    auto count = facts.get<integer_value>(fact::physical_processor_count);
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(0, count->value());

    count = facts.get<integer_value>(fact::processor_count);
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(0, count->value());

    auto processors = facts.get<map_value>(fact::processors);
    ASSERT_NE(nullptr, processors);
    ASSERT_EQ(2u, processors->size());

    count = processors->get<integer_value>("count");
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(0, count->value());

    count = processors->get<integer_value>("physicalcount");
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(0, count->value());
}

TEST(facter_facts_resolvers_processor_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_processor_resolver>());
    ASSERT_EQ(8u, facts.size());

    auto count = facts.get<integer_value>(fact::physical_processor_count);
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(2u, count->value());

    count = facts.get<integer_value>(fact::processor_count);
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(4u, count->value());

    auto isa = facts.get<string_value>(fact::hardware_isa);
    ASSERT_NE(nullptr, isa);
    ASSERT_EQ("isa", isa->value());

    for (size_t i = 0; i < 4; ++i) {
        auto model = facts.get<string_value>(fact::processor + to_string(i));
        ASSERT_NE(nullptr, model);
        ASSERT_EQ("processor" + to_string(i + 1), model->value());
    }

    auto processors = facts.get<map_value>(fact::processors);
    ASSERT_NE(nullptr, processors);
    ASSERT_EQ(5u, processors->size());

    count = processors->get<integer_value>("count");
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(4u, count->value());

    count = processors->get<integer_value>("physicalcount");
    ASSERT_NE(nullptr, count);
    ASSERT_EQ(2u, count->value());

    isa = processors->get<string_value>("isa");
    ASSERT_NE(nullptr, isa);
    ASSERT_EQ("isa", isa->value());

    auto models = processors->get<array_value>("models");
    ASSERT_NE(nullptr, models);
    ASSERT_EQ(4u, models->size());

    for (size_t i = 0; i < 4; ++i) {
        auto model = models->get<string_value>(i);
        ASSERT_NE(nullptr, model);
        ASSERT_EQ("processor" + to_string(i + 1), model->value());
    }

    auto speed = processors->get<string_value>("speed");
    ASSERT_NE(nullptr, speed);
    ASSERT_EQ("10.00 GHz", speed->value());
}
