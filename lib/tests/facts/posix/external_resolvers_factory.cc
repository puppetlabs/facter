#include <catch.hpp>
#include <facter/facts/external_resolvers_factory.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;

SCENARIO("checking external file posix resolvers factory") {
    external_resolvers_factory erf;
    GIVEN("a non-executable file") {
        THEN("the file cannot be resolved") {
            REQUIRE_THROWS_AS(erf.get_resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/not_executable"),
                              external::external_fact_no_resolver&);
        }
    }
    GIVEN("a executable file") {
        THEN("the file can be resolved") {
            REQUIRE(erf.get_resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts"));
        }
    }
    GIVEN("a relative path not on PATH") {
        THEN("the file cannot be resolved") {
            REQUIRE_THROWS_AS(erf.get_resolver("foo/bar.bat"),
                              external::external_fact_no_resolver&);
        }
    }
}
