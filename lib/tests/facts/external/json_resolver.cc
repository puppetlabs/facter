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

SCENARIO("resolving external JSON facts") {
    collection facts;
    json_resolver resolver;

    GIVEN("a non-JSON file extension") {
        THEN("it should not be able to resolve") {
            REQUIRE_FALSE(resolver.can_resolve("foo.txt"));
        }
    }
    GIVEN("a JSON file extension") {
        THEN("it should be able to resolve") {
            REQUIRE(resolver.can_resolve("foo.json"));
            REQUIRE(resolver.can_resolve("FoO.jsOn"));
        }
    }
    GIVEN("a non-existent file to resolve") {
        THEN("it should throw an exception") {
            REQUIRE_THROWS_AS(resolver.resolve("doesnotexist.json", facts), external_fact_exception);
        }
    }
    GIVEN("invalid JSON") {
        THEN("it should throw an exception") {
            REQUIRE_THROWS_AS(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json/invalid.json", facts), external_fact_exception);
        }
    }
    GIVEN("valid JSON") {
        THEN("it should populate the facts") {
            resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json/facts.json", facts);
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
