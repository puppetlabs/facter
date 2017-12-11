#include <catch.hpp>
#include <internal/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <leatherman/util/regex.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
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
        WHEN("the output is json") {
            THEN("it populates facts from the json") {
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/json.ps1", facts);
                REQUIRE(!facts.empty());

                REQUIRE_FALSE(facts.get<string_value>("PS1_JSON_FACT1"));
                REQUIRE(facts.get<string_value>("ps1_json_fact1"));
                REQUIRE(facts.get<string_value>("ps1_json_fact1")->value() == "value1");

                REQUIRE(facts.get<integer_value>("ps1_json_fact2"));
                REQUIRE(facts.get<integer_value>("ps1_json_fact2")->value() == 2);

                REQUIRE(facts.get<boolean_value>("ps1_json_fact3"));
                REQUIRE(facts.get<boolean_value>("ps1_json_fact3")->value());

                auto array = facts.get<array_value>("ps1_json_fact4");
                REQUIRE(array);
                REQUIRE(array->size() == 2u);

                REQUIRE_FALSE(facts.get<boolean_value>("ps1_json_fact5"));

                auto map = facts.get<map_value>("ps1_json_fact6");
                REQUIRE(map);
                REQUIRE(map->size() == 2u);
            }
        }
        WHEN("the output is yaml") {
            THEN("it populates facts from the yaml") {
                resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell/yaml.ps1", facts);
                REQUIRE(!facts.empty());

                REQUIRE_FALSE(facts.get<integer_value>("PS1_YAML_FACT1"));
                REQUIRE(facts.get<string_value>("ps1_yaml_fact1"));
                REQUIRE(facts.get<string_value>("ps1_yaml_fact1")->value() == "yaml");

                REQUIRE(facts.get<integer_value>("ps1_yaml_fact2"));
                REQUIRE(facts.get<integer_value>("ps1_yaml_fact2")->value() == 2);

                REQUIRE(facts.get<string_value>("ps1_yaml_fact3"));
                REQUIRE(facts.get<string_value>("ps1_yaml_fact3")->value() == "one value\nbut\nmany lines\n");

                auto array1 = facts.get<array_value>("ps1_yaml_fact4");
                REQUIRE(array1);
                REQUIRE(array1->size() == 2u);

                auto array2 = facts.get<array_value>("ps1_yaml_fact5");
                REQUIRE(array2);
                REQUIRE(array2->size() == 3u);

                auto map1 = facts.get<map_value>("ps1_yaml_fact6");
                REQUIRE(map1);
                REQUIRE(map1->size() == 3u);

                auto map2 = facts.get<map_value>("ps1_yaml_fact7");
                REQUIRE(map2);
                REQUIRE(map2->size() == 1u);
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
