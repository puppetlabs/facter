#include <catch.hpp>
#include <internal/facts/external/yaml_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;
using namespace facter::testing;

SCENARIO("resolving external YAML facts") {
    collection_fixture facts;

    GIVEN("a non-existent file to resolve") {
        THEN("it should throw an exception") {
            yaml_resolver resolver("doesnotexist.yaml");
            REQUIRE_THROWS_AS(resolver.resolve(facts), external_fact_exception&);
        }
    }
    GIVEN("invalid YAML") {
        THEN("it should throw an exception") {
            yaml_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml/invalid.yaml");
            REQUIRE_THROWS_AS(resolver.resolve(facts), external_fact_exception&);
        }
    }
    GIVEN("valid YAML") {
        THEN("it should populate the facts") {
            yaml_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml/facts.yaml");
            resolver.resolve(facts);
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
            REQUIRE(array->size() == 3u);
            auto map = facts.get<map_value>("yaml_fact6");
            REQUIRE(map);
            REQUIRE(map->size() == 2u);
            REQUIRE(facts.get<string_value>("yaml_fact7"));
            REQUIRE_FALSE(facts.get<string_value>("YAML_fact7"));
            REQUIRE(facts.get<string_value>("yaml_fact7")->value() == "bar");
            REQUIRE(facts.get<string_value>("yaml_fact7")->value() == "bar");
            REQUIRE(facts.get<string_value>("yaml_fact7")->value() == "bar");
            REQUIRE(facts.get<string_value>("not_bool"));
            REQUIRE(facts.get<string_value>("not_bool")->value() == "true");
            REQUIRE(facts.get<string_value>("not_int"));
            REQUIRE(facts.get<string_value>("not_int")->value() == "123");
            REQUIRE(facts.get<string_value>("not_double"));
            REQUIRE(facts.get<string_value>("not_double")->value() == "123.456");
        }
    }
}
