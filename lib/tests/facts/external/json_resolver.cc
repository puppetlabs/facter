#include <catch.hpp>
#include <internal/facts/external/json_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;
using namespace facter::testing;

SCENARIO("resolving external JSON facts") {
    collection_fixture facts;

    GIVEN("a non-existent file to resolve") {
        THEN("it should throw an exception") {
            json_resolver resolver("doesnotexist.json");
            REQUIRE_THROWS_AS(resolver.resolve(facts), external_fact_exception&);
        }
    }
    GIVEN("invalid JSON") {
        THEN("it should throw an exception") {
            json_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json/invalid.json");
            REQUIRE_THROWS_AS(resolver.resolve(facts), external_fact_exception&);
        }
    }
    GIVEN("valid JSON") {
        THEN("it should populate the facts") {
            json_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json/facts.json");
            resolver.resolve(facts);
            REQUIRE_FALSE(facts.empty());
            REQUIRE(facts.get<string_value>("json_fact1"));
            REQUIRE(facts.get<string_value>("json_fact1")->value() == "foo");
            REQUIRE(facts.get<integer_value>("json_fact2"));
            REQUIRE(facts.get<integer_value>("json_fact2")->value() == 5);
            REQUIRE(facts.get<boolean_value>("json_fact3"));
            REQUIRE(facts.get<boolean_value>("json_fact3")->value());
            REQUIRE(facts.get<double_value>("json_fact4"));
            REQUIRE(facts.get<double_value>("json_fact4")->value() == Approx(5.1));
            auto array = facts.get<array_value>("json_fact5");
            REQUIRE(array);
            REQUIRE(array->size() == 3u);
            auto map = facts.get<map_value>("json_fact6");
            REQUIRE(map);
            REQUIRE(map->size() == 2u);
            REQUIRE(facts.get<string_value>("json_fact7"));
            REQUIRE_FALSE(facts.get<string_value>("JSON_fact7"));
            REQUIRE(facts.get<string_value>("json_fact7")->value() == "bar");
        }
    }
}
