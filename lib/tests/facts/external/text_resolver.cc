#include <gmock/gmock.h>
#include <facter/facts/external/text_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;

TEST(facter_facts_external_text_resolver, default_constructor) {
    text_resolver resolver;
}

TEST(facter_facts_external_text_resolver, resolve_non_text) {
    text_resolver resolver;
    fact_map facts;
    ASSERT_FALSE(resolver.resolve("foo.json", facts));
}

TEST(facter_facts_external_text_resolver, resolve_nonexistent_text) {
    text_resolver resolver;
    fact_map facts;
    ASSERT_THROW(resolver.resolve("doesnotexist.txt", facts), external_fact_exception);
}

TEST(facter_facts_external_text_resolver, resolve_text) {
    text_resolver resolver;
    fact_map facts;
    ASSERT_TRUE(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text/facts.txt", facts));
    ASSERT_TRUE(!facts.empty());
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact1"));
    ASSERT_EQ("value1", facts.get<string_value>("txt_fact1")->value());
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact2"));
    ASSERT_EQ("", facts.get<string_value>("txt_fact2")->value());
    ASSERT_EQ(nullptr, facts.get<string_value>("txt_fact3"));
}
