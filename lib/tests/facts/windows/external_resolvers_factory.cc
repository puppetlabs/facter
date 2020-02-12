#include <catch.hpp>
#include <facter/facts/external_resolvers_factory.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;

SCENARIO("checking external file windows resolvers factory") {
    external_resolvers_factory erf;
    GIVEN("an executable file") {
        THEN("the file can be resolved") {
            REQUIRE(erf.get_resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat"));
        }
    }
    GIVEN("a PowerShell file extension") {
        THEN("the file can be resolved") {
            REQUIRE(erf.get_resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/facts.ps1"));
        }
    }
    GIVEN("a non executable file without extension") {
        THEN("should throw no resolver exception") {
            REQUIRE_THROWS_AS(erf.get_resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/not_executable"),
                              external::external_fact_no_resolver&);
        }
    }
    GIVEN("a non-executable ruby script") {
        THEN("the file cannot be resolved") {
            REQUIRE_THROWS_AS(erf.get_resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/ruby_script.rb"),
                              external::external_fact_no_resolver&);
        }
    }
    GIVEN("a relative path not on PATH") {
        THEN("the file cannot be resolved") {
            REQUIRE_THROWS_AS(erf.get_resolver("foo/bar.bat"),
                              external::external_fact_no_resolver&);
        }
    }
}
