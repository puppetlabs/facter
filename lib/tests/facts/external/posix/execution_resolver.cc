#include <catch.hpp>
#include <internal/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include "../../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::facts::external;
using namespace facter::testing;

SCENARIO("resolving external executable facts") {
    collection facts;
    execution_resolver resolver;

    GIVEN("a non-executable file") {
        THEN("the file cannot be resolved") {
            REQUIRE_FALSE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/not_executable"));
        }
    }
    GIVEN("an executable file") {
        WHEN("the execution fails") {
            THEN("an exception is thrown") {
                REQUIRE_THROWS_AS(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/failed", facts), external_fact_exception);
            }
        }
        WHEN("the execution succeeds") {
            THEN("it populates facts") {
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts", facts);
                REQUIRE(!facts.empty());
                REQUIRE(facts.get<string_value>("exe_fact1"));
                REQUIRE(facts.get<string_value>("exe_fact1")->value() == "value1");
                REQUIRE(facts.get<string_value>("exe_fact2"));
                REQUIRE(facts.get<string_value>("exe_fact2")->value() == "");
                REQUIRE_FALSE(facts.get<string_value>("exe_fact3"));
                REQUIRE(facts.get<string_value>("exe_fact4"));
                REQUIRE_FALSE(facts.get<string_value>("EXE_fact4"));
                REQUIRE(facts.get<string_value>("exe_fact4")->value() == "value2");
            }
        }
        THEN("the file can be resolved") {
            REQUIRE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts"));
        }
    }
    GIVEN("a relative path not on PATH") {
        test_with_relative_path fixture("foo", "bar", "");
        THEN("the file cannot be resolved") {
            REQUIRE_FALSE(resolver.can_resolve("foo/bar"));
        }
    }
}
