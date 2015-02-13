#include <gmock/gmock.h>
#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include "../../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::facts::external;
using namespace facter::testing;

TEST(facter_facts_external_windows_execution_resolver, default_constructor) {
    execution_resolver resolver;
}

TEST(facter_facts_external_windows_execution_resolver, can_resolve) {
    execution_resolver resolver;
    ASSERT_FALSE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/not_executable"));
    ASSERT_FALSE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/ruby_script.rb"));
    ASSERT_TRUE(resolver.can_resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat"));
}

TEST(facter_facts_external_windows_execution_resolver, can_resolve_relative_fails) {
    test_with_relative_path fixture("foo.bat", "");

    execution_resolver resolver;
    ASSERT_FALSE(resolver.can_resolve(fixture.filename()));
}

TEST(facter_facts_external_windows_execution_resolver, resolve_failed_execution) {
    execution_resolver resolver;
    collection facts;
    ASSERT_THROW(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/failed.cmd", facts), external_fact_exception);
}

TEST(facter_facts_external_windows_execution_resolver, resolve_execution) {
    execution_resolver resolver;
    collection facts;
    resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat", facts);
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

TEST(facter_facts_external_windows_execution_resolver, resolve_execution_relative_fails) {
    test_with_relative_path fixture("foo.bat", "");

    execution_resolver resolver;
    collection facts;
    ASSERT_THROW(resolver.resolve(fixture.filename(), facts), external_fact_exception);
}
