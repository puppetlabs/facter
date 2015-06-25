#include <catch.hpp>
#include <internal/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <internal/util/regex.hpp>
#include "../../../fixtures.hpp"
#include "../../../log_capture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::facts::external;
using namespace facter::logging;
using namespace facter::testing;

SCENARIO("resolving external executable facts") {
    collection_fixture facts;
    execution_resolver resolver;

    GIVEN("a non-executable file") {
        THEN("the file cannot be resolved") {
            REQUIRE_FALSE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/not_executable"));
            REQUIRE_FALSE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/ruby_script.rb"));
        }
    }
    GIVEN("an executable file") {
        WHEN("the execution fails") {
            THEN("an exception is thrown") {
                REQUIRE_THROWS_AS(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/failed.cmd", facts), external_fact_exception);
            }
        }
        WHEN("the execution succeeds") {
            THEN("it populates facts") {
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat", facts);
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
        WHEN("messages are logged to stderr") {
            THEN("a warning is generated") {
                log_capture capture(level::warning);
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/error_message.bat", facts);
                REQUIRE(facts.size() == 1u);
                REQUIRE(facts.get<string_value>("foo"));
                REQUIRE(facts.get<string_value>("foo")->value() == "bar");
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - external fact file \".*error_message.bat\" had output on stderr: error message!")));
            }
        }
        THEN("the file can be resolved") {
            REQUIRE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat"));
        }
    }
    GIVEN("a relative path not on PATH") {
        test_with_relative_path fixture("foo", "bar.bar", "");
        THEN("the file cannot be resolved") {
            REQUIRE_FALSE(resolver.can_resolve("foo/bar.bat"));
        }
    }
}
