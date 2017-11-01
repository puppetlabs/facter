#include <catch.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace facter::testing;

SCENARIO("resolving external executable facts into a collection") {
    collection_fixture facts;
    REQUIRE(facts.size() == 0u);
    GIVEN("an absolute path") {
        facts.add_external_facts({
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution",
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/powershell",
        });
        THEN("facts should resolve") {
            REQUIRE(facts.size() == 19u);

            REQUIRE(facts.get<string_value>("exe_fact1"));
            REQUIRE(facts.get<string_value>("exe_fact2"));
            REQUIRE_FALSE(facts.get<string_value>("exe_fact3"));
            REQUIRE(facts.get<string_value>("exe_fact4"));

            REQUIRE(facts.get<string_value>("ps1_fact1"));
            REQUIRE(facts.get<string_value>("ps1_fact2"));
            REQUIRE_FALSE(facts.get<string_value>("ps1_fact3"));
            REQUIRE(facts.get<string_value>("ps1_fact4"));

            REQUIRE(facts.get<string_value>("ps1_json_fact1"));
            REQUIRE(facts.get<integer_value>("ps1_json_fact2"));
            REQUIRE(facts.get<boolean_value>("ps1_json_fact3"));
            REQUIRE(facts.get<array_value>("ps1_json_fact4"));
            REQUIRE_FALSE(facts.get<boolean_value>("ps1_json_fact5"));
            REQUIRE(facts.get<map_value>("ps1_json_fact6"));

            REQUIRE(facts.get<string_value>("ps1_yaml_fact1"));
            REQUIRE(facts.get<integer_value>("ps1_yaml_fact2"));
            REQUIRE(facts.get<string_value>("ps1_yaml_fact3"));
            REQUIRE(facts.get<array_value>("ps1_yaml_fact4"));
            REQUIRE(facts.get<array_value>("ps1_yaml_fact5"));
            REQUIRE(facts.get<map_value>("ps1_yaml_fact6"));
            REQUIRE(facts.get<map_value>("ps1_yaml_fact7"));
        }
    }
    GIVEN("a relative path") {
        test_with_relative_path fixture("foo", "bar.bat", "@echo local_exec_fact=value");
        facts.add_external_facts({ "foo" });
        THEN("facts should resolve") {
            REQUIRE(facts.size() == 1u);
            REQUIRE(facts.get<string_value>("local_exec_fact"));
            REQUIRE(facts.get<string_value>("local_exec_fact")->value() == "value");
        }
    }
}
