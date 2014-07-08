#include <gmock/gmock.h>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../fixtures.hpp"
#include <iostream>

using namespace std;
using namespace facter::facts;

TEST(facter_facts_fact_map, default_constructor) {
    fact_map facts;
    ASSERT_FALSE(facts.empty());
    ASSERT_FALSE(facts.resolved());
    ASSERT_EQ(1u, facts.size());
}

TEST(facter_facts_fact_map, simple_fact) {
    fact_map facts;
    facts.clear();
    facts.add("foo", make_value<string_value>("bar"));
    ASSERT_EQ(1u, facts.size());
    ASSERT_FALSE(facts.empty());
    ASSERT_TRUE(facts.resolved());
    auto fact = facts.get<string_value>("foo");
    ASSERT_NE(nullptr, fact);
    ASSERT_EQ("bar", fact->value());
    fact = dynamic_cast<string_value const*>(facts["foo"]);
    ASSERT_NE(nullptr, fact);
    ASSERT_EQ("bar", fact->value());
}

struct simple_resolver : resolver
{
    simple_resolver() : resolver("test", { "foo" })
    {
    }

 protected:
    virtual void resolve_facts(fact_map& facts)
    {
        facts.add("foo", make_value<string_value>("bar"));
    }
};

TEST(facter_facts_fact_map, simple_resolver) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<simple_resolver>());
    ASSERT_FALSE(facts.empty());
    ASSERT_FALSE(facts.resolved());
    ASSERT_EQ(0u, facts.size());
    ASSERT_EQ("bar", facts.get<string_value>("foo")->value());
    ASSERT_TRUE(facts.resolved());
    ASSERT_EQ(1u, facts.size());
}

struct multi_resolver : resolver
{
    multi_resolver() : resolver("test", { "foo", "bar" })
    {
    }

 protected:
    virtual void resolve_facts(fact_map& facts)
    {
        facts.add("foo", make_value<string_value>("bar"));
        facts.add("bar", make_value<string_value>("foo"));
    }
};

TEST(facter_facts_fact_map, resolve_specific) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<multi_resolver>());
    ASSERT_FALSE(facts.empty());
    ASSERT_FALSE(facts.resolved());
    facts.resolve({ "bar" });
    ASSERT_TRUE(facts.resolved());
    ASSERT_EQ(1u, facts.size());
    ASSERT_EQ(nullptr, facts.get<string_value>("foo"));
    ASSERT_EQ("foo", facts.get<string_value>("bar")->value());
}

TEST(facter_facts_fact_map, resolve_external) {
    fact_map facts;
    facts.clear();
    ASSERT_TRUE(facts.empty());
    ASSERT_TRUE(facts.resolved());
    facts.resolve_external({
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution",
    });
    ASSERT_FALSE(facts.empty());
    ASSERT_TRUE(facts.resolved());
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

TEST(facter_facts_fact_map, each) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<multi_resolver>());
    size_t count = 0;
    bool failed_foo = true;
    bool failed_bar = true;
    facts.resolve();
    facts.each([&](string const& name, value const* val) {
        auto string_val = dynamic_cast<string_value const*>(val);
        if (string_val) {
            if (name == "foo") {
                failed_foo = string_val->value() != "bar";
            } else if (name == "bar") {
                failed_bar = string_val->value() != "foo";
            }
        }
        ++count;
        return true;
    });
    ASSERT_EQ(2u, count);
    ASSERT_FALSE(failed_foo);
    ASSERT_FALSE(failed_bar);
}

TEST(facter_facts_fact_map, write_json) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<multi_resolver>());
    facts.resolve();
    ostringstream ss;
    facts.write_json(ss);
    ASSERT_EQ("{\n  \"bar\": \"foo\",\n  \"foo\": \"bar\"\n}", ss.str());
}

TEST(facter_facts_fact_map, write_yaml) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<multi_resolver>());
    facts.resolve();
    ostringstream ss;
    facts.write_yaml(ss);
    ASSERT_EQ("bar: \"foo\"\nfoo: \"bar\"", ss.str());
}

TEST(facter_facts_fact_map, insertion_operator) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<multi_resolver>());
    facts.resolve();
    ostringstream ss;
    ss << facts;
    ASSERT_EQ("bar => foo\nfoo => bar", ss.str());
}

TEST(facter_facts_fact_map, insertion_operator_simple) {
    fact_map facts;
    facts.clear();
    facts.add(make_shared<simple_resolver>());
    facts.resolve();
    ostringstream ss;
    ss << facts;
    ASSERT_EQ("bar", ss.str());
}
