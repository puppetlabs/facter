#include <catch.hpp>
#include <internal/facts/external/text_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;
using namespace facter::testing;

SCENARIO("resolving external text facts") {
    collection_fixture facts;

    GIVEN("a non-existent file to resolve") {
        THEN("it should throw an exception") {
          text_resolver resolver("doesnotexist.txt");
          REQUIRE_THROWS_AS(resolver.resolve(facts), external_fact_exception&);
        }
    }
    GIVEN("a text file to resolve") {
        THEN("it should populate the facts") {
            text_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text/facts.txt");
            resolver.resolve(facts);
            REQUIRE_FALSE(facts.empty());
            REQUIRE(facts.get<string_value>("txt_fact1"));
            REQUIRE(facts.get<string_value>("txt_fact1")->value() == "value1");
            REQUIRE(facts.get<string_value>("txt_fact2"));
            REQUIRE(facts.get<string_value>("txt_fact2")->value() == "");
            REQUIRE_FALSE(facts.get<string_value>("txt_fact3"));
            REQUIRE(facts.get<string_value>("txt_fact4"));
            REQUIRE_FALSE(facts.get<string_value>("TXT_Fact4"));
            REQUIRE(facts.get<string_value>("txt_fact4")->value() == "value2");
        }
    }
}
