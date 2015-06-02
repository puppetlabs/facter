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
    collection facts;
    REQUIRE(facts.size() == 0u);
    GIVEN("an absolute path") {
        facts.add_external_facts({
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution",
        });
        THEN("facts should resolve") {
            REQUIRE(facts.size() == 4u);
            REQUIRE(facts.get<string_value>("exe_fact1"));
            REQUIRE(facts.get<string_value>("exe_fact2"));
            REQUIRE_FALSE(facts.get<string_value>("exe_fact3"));
            REQUIRE(facts.get<string_value>("exe_fact4"));
            REQUIRE(facts.get<string_value>("foo"));
        }
    }
    GIVEN("a relative path") {
        test_with_relative_path fixture("foo", "bar", "#! /usr/bin/env sh\necho local_exec_fact=value");
        facts.add_external_facts({ "foo" });
        THEN("facts should resolve") {
            REQUIRE(facts.size() == 1u);
            REQUIRE(facts.get<string_value>("local_exec_fact"));
            REQUIRE(facts.get<string_value>("local_exec_fact")->value() == "value");
        }
    }
}
