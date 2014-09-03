#include <gmock/gmock.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"
#include <sstream>

using namespace std;
using namespace facter::facts;

TEST(facter_facts_collection, resolve_external) {
    collection facts;
    ASSERT_EQ(0u, facts.size());
    ASSERT_TRUE(facts.empty());
    facts.add_external_facts({
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution",
    });
    ASSERT_FALSE(facts.empty());
    ASSERT_EQ(20u, facts.size());
    ASSERT_NE(nullptr, facts.get<string_value>("yaml_fact1"));
    ASSERT_NE(nullptr, facts.get<integer_value>("yaml_fact2"));
    ASSERT_NE(nullptr, facts.get<boolean_value>("yaml_fact3"));
    ASSERT_NE(nullptr, facts.get<double_value>("yaml_fact4"));
    ASSERT_NE(nullptr, facts.get<array_value>("yaml_fact5"));
    ASSERT_NE(nullptr, facts.get<map_value>("yaml_fact6"));
    ASSERT_NE(nullptr, facts.get<string_value>("yaml_fact7"));
    ASSERT_NE(nullptr, facts.get<string_value>("json_fact1"));
    ASSERT_NE(nullptr, facts.get<integer_value>("json_fact2"));
    ASSERT_NE(nullptr, facts.get<boolean_value>("json_fact3"));
    ASSERT_NE(nullptr, facts.get<double_value>("json_fact4"));
    ASSERT_NE(nullptr, facts.get<array_value>("json_fact5"));
    ASSERT_NE(nullptr, facts.get<map_value>("json_fact6"));
    ASSERT_NE(nullptr, facts.get<string_value>("json_fact7"));
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact1"));
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact2"));
    ASSERT_EQ(nullptr, facts.get<string_value>("exe_fact3"));
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact4"));
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact1"));
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact2"));
    ASSERT_EQ(nullptr, facts.get<string_value>("txt_fact3"));
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact4"));
}
