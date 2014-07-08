#include <gmock/gmock.h>
#include <facter/facts/external/json_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::external;

TEST(facter_facts_external_json_resolver, default_constructor) {
    json_resolver resolver;
}

TEST(facter_facts_external_json_resolver, resolve_non_json) {
    json_resolver resolver;
    collection facts;
    ASSERT_FALSE(resolver.resolve("notjson.txt", facts));
}

TEST(facter_facts_external_json_resolver, resolve_nonexistent_json) {
    json_resolver resolver;
    collection facts;
    ASSERT_THROW(resolver.resolve("foo.json", facts), external_fact_exception);
}

TEST(facter_facts_external_json_resolver, resolve_invalid_json) {
    json_resolver resolver;
    collection facts;
    ASSERT_THROW(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json/invalid.json", facts), external_fact_exception);
}

TEST(facter_facts_external_json_resolver, resolve_json) {
    json_resolver resolver;
    collection facts;
    ASSERT_TRUE(resolver.resolve(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json/facts.json", facts));
    ASSERT_TRUE(!facts.empty());
    ASSERT_NE(nullptr, facts.get<string_value>("json_fact1"));
    ASSERT_EQ("foo", facts.get<string_value>("json_fact1")->value());
    ASSERT_NE(nullptr, facts.get<integer_value>("json_fact2"));
    ASSERT_EQ(5, facts.get<integer_value>("json_fact2")->value());
    ASSERT_NE(nullptr, facts.get<boolean_value>("json_fact3"));
    ASSERT_TRUE(facts.get<boolean_value>("json_fact3")->value());
    ASSERT_NE(nullptr, facts.get<double_value>("json_fact4"));
    ASSERT_DOUBLE_EQ(5.1, facts.get<double_value>("json_fact4")->value());
    auto array = facts.get<array_value>("json_fact5");
    ASSERT_NE(nullptr, array);
    ASSERT_EQ(3u, array->size());
    auto map = facts.get<map_value>("json_fact6");
    ASSERT_NE(nullptr, map);
    ASSERT_EQ(2u, map->size());
    ASSERT_NE(nullptr, facts.get<string_value>("json_fact7"));
    ASSERT_EQ(nullptr, facts.get<string_value>("JSON_fact7"));
    ASSERT_EQ("bar", facts.get<string_value>("json_fact7")->value());
}
