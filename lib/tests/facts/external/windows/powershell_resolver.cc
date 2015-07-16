#include <catch.hpp>
#include <internal/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <leatherman/util/regex.hpp>
#include "../../../fixtures.hpp"
#include "../../../log_capture.hpp"

using namespace std;
using namespace facter::facts;
using namespace leatherman::util;
using namespace facter::logging;
using namespace facter::testing;
using namespace facter::facts::external;

SCENARIO("resolving external powershell facts") {
    collection_fixture facts;
    powershell_resolver resolver;

    GIVEN("a non-powershell file") {
        THEN("the file cannot be resolved") {
            REQUIRE_FALSE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/not_executable"));
        }
    }
    GIVEN("a powershell file") {
        WHEN("the execution fails") {
            THEN("an exception is thrown") {
                REQUIRE_THROWS_AS(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/failed.ps1", facts), external_fact_exception);
            }
        }
        WHEN("the execution succeeds") {
            THEN("it populates facts") {
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/facts.ps1", facts);
                REQUIRE(!facts.empty());
                REQUIRE(facts.get<string_value>("ps1_fact1"));
                REQUIRE(facts.get<string_value>("ps1_fact1")->value() == "value1");
                REQUIRE(facts.get<string_value>("ps1_fact2"));
                REQUIRE(facts.get<string_value>("ps1_fact2")->value() == "");
                REQUIRE_FALSE(facts.get<string_value>("ps1_fact3"));
                REQUIRE(facts.get<string_value>("ps1_fact4"));
                REQUIRE_FALSE(facts.get<string_value>("PS1_fact4"));
                REQUIRE(facts.get<string_value>("ps1_fact4")->value() == "value2");
            }
        }
        WHEN("messages are logged to stderr") {
            THEN("a warning is generated") {
                log_capture capture(level::warning);
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/error_message.ps1", facts);
                REQUIRE(facts.size() == 1u);
                REQUIRE(facts.get<string_value>("foo"));
                REQUIRE(facts.get<string_value>("foo")->value() == "bar");
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - external fact file \".*error_message.ps1\" had output on stderr: error message!")));
            }
        }
        THEN("the file can be resolved") {
            REQUIRE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/facts.ps1"));
        }
    }
}
