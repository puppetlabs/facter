#include <catch.hpp>
#include <internal/facts/resolvers/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

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

SCENARIO("using the processor resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_processor_resolver>());
        THEN("only the processor counts are present and are zero") {
            REQUIRE(facts.size() == 3u);
            auto count = facts.get<integer_value>(fact::physical_processor_count);
            REQUIRE(count);
            REQUIRE(count->value() == 0);
            count = facts.get<integer_value>(fact::processor_count);
            REQUIRE(count);
            REQUIRE(count->value() == 0);
            auto processors = facts.get<map_value>(fact::processors);
            REQUIRE(processors);
            REQUIRE(processors->size() == 2u);
            count = processors->get<integer_value>("count");
            REQUIRE(count);
            REQUIRE(count->value() == 0);
            count = processors->get<integer_value>("physicalcount");
            REQUIRE(count);
            REQUIRE(count->value() == 0);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_processor_resolver>());
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 8u);
            auto processors = facts.get<map_value>(fact::processors);
            REQUIRE(processors);
            REQUIRE(processors->size() == 5u);
            auto count = processors->get<integer_value>("count");
            REQUIRE(count);
            REQUIRE(count->value() == 4);
            count = processors->get<integer_value>("physicalcount");
            REQUIRE(count);
            REQUIRE(count->value() == 2);
            auto isa = processors->get<string_value>("isa");
            REQUIRE(isa);
            REQUIRE(isa->value() == "isa");
            auto models = processors->get<array_value>("models");
            REQUIRE(models);
            REQUIRE(models->size() == 4u);
            for (size_t i = 0; i < 4; ++i) {
                auto model = models->get<string_value>(i);
                REQUIRE(model);
                REQUIRE(model->value() == "processor" + to_string(i + 1));
            }
            auto speed = processors->get<string_value>("speed");
            REQUIRE(speed);
            REQUIRE(speed->value() == "10.00 GHz");
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 8u);
            auto count = facts.get<integer_value>(fact::physical_processor_count);
            REQUIRE(count);
            REQUIRE(count->value() == 2);
            count = facts.get<integer_value>(fact::processor_count);
            REQUIRE(count);
            REQUIRE(count->value() == 4);
            auto isa = facts.get<string_value>(fact::hardware_isa);
            REQUIRE(isa);
            REQUIRE(isa->value() == "isa");
            for (size_t i = 0; i < 4; ++i) {
                auto model = facts.get<string_value>(fact::processor + to_string(i));
                REQUIRE(model);
                REQUIRE(model->value() == "processor" + to_string(i + 1));
            }
        }
    }
}
