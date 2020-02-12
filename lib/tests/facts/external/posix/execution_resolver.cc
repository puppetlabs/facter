#include <catch.hpp>
#include <internal/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <leatherman/util/regex.hpp>
#include "../../../fixtures.hpp"
#include "../../../log_capture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::facts::external;
using namespace facter::logging;
using namespace facter::testing;
using namespace leatherman::util;

SCENARIO("resolving external executable facts") {
    collection_fixture facts;

    GIVEN("an executable file") {
        WHEN("the execution fails") {
            THEN("an exception is thrown") {
                execution_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/failed");
                REQUIRE_THROWS_AS(resolver.resolve(facts), external_fact_exception&);
            }
        }
        WHEN("the execution succeeds") {
            THEN("it populates facts") {
                execution_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts");
                resolver.resolve(facts);
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
                execution_resolver resolver(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/error_message");
                resolver.resolve(facts);
                REQUIRE(facts.size() == 1u);
                REQUIRE(facts.get<string_value>("foo"));
                REQUIRE(facts.get<string_value>("foo")->value() == "bar");
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - external fact file \".*/error_message\" had output on stderr: error message!")));
            }
        }
    }
}
