#include <gmock/gmock.h>
#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;

TEST(facter_facts_external_posix_execution_resolver, default_constructor) {
    execution_resolver resolver;
}

TEST(facter_facts_external_posix_execution_resolver, resolve_nonexistent_execution) {
    execution_resolver resolver;
    fact_map facts;
    ASSERT_FALSE(resolver.resolve("does_not_exist", facts));
}

TEST(facter_facts_external_posix_execution_resolver, resolve_not_executable) {
    execution_resolver resolver;
    fact_map facts;
    ASSERT_FALSE(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/not_executable", facts));
}

TEST(facter_facts_external_posix_execution_resolver, resolve_failed_execution) {
    execution_resolver resolver;
    fact_map facts;
    ASSERT_THROW(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/failed", facts), external_fact_exception);
}

TEST(facter_facts_external_posix_execution_resolver, resolve_execution) {
    execution_resolver resolver;
    fact_map facts;
    ASSERT_TRUE(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts", facts));
    ASSERT_TRUE(!facts.empty());
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact1"));
    ASSERT_EQ("value1", facts.get<string_value>("exe_fact1")->value());
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact2"));
    ASSERT_EQ("", facts.get<string_value>("exe_fact2")->value());
    ASSERT_EQ(nullptr, facts.get<string_value>("exe_fact3"));
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact4"));
    ASSERT_EQ(nullptr, facts.get<string_value>("EXE_fact4"));
    ASSERT_EQ("value2", facts.get<string_value>("exe_fact4")->value());
}
