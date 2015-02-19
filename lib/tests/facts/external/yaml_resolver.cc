#include <catch.hpp>
#include <facter/facts/external/yaml_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;

SCENARIO("resolving external YAML facts") {
    collection facts;
    yaml_resolver resolver;

    GIVEN("a non-YAML file extension") {
        THEN("it should not be able to resolve") {
            REQUIRE_FALSE(resolver.can_resolve("foo.txt"));
        }
    }
    GIVEN("a YAML file extension") {
        THEN("it should be able to resolve") {
            REQUIRE(resolver.can_resolve("foo.yaml"));
            REQUIRE(resolver.can_resolve("FoO.yAmL"));
        }
    }
    GIVEN("a non-existent file to resolve") {
        THEN("it should throw an exception") {
            REQUIRE_THROWS_AS(resolver.resolve("doesnotexist.yaml", facts), external_fact_exception);
        }
    }
    GIVEN("invalid YAML") {
        THEN("it should throw an exception") {
            REQUIRE_THROWS_AS(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml/invalid.yaml", facts), external_fact_exception);
        }
    }
    GIVEN("valid YAML") {
        THEN("it should populate the facts") {
            resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml/facts.yaml", facts);
            REQUIRE_FALSE(facts.empty());
            REQUIRE(facts.get<string_value>("yaml_fact1"));
            REQUIRE(facts.get<string_value>("yaml_fact1")->value() == "foo");
            REQUIRE(facts.get<integer_value>("yaml_fact2"));
            REQUIRE(facts.get<integer_value>("yaml_fact2")->value() == 5);
            REQUIRE(facts.get<boolean_value>("yaml_fact3"));
            REQUIRE(facts.get<boolean_value>("yaml_fact3")->value());
            REQUIRE(facts.get<double_value>("yaml_fact4"));
            REQUIRE(facts.get<double_value>("yaml_fact4")->value() == Approx(5.1));
            auto array = facts.get<array_value>("yaml_fact5");
            REQUIRE(array);
            REQUIRE(array->size() == 3);
            auto map = facts.get<map_value>("yaml_fact6");
            REQUIRE(map);
            REQUIRE(map->size() == 2);
            REQUIRE(facts.get<string_value>("yaml_fact7"));
            REQUIRE_FALSE(facts.get<string_value>("YAML_fact7"));
            REQUIRE(facts.get<string_value>("yaml_fact7")->value() == "bar");
        }
    }
}
