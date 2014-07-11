#include <gmock/gmock.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../fixtures.hpp"
#include <sstream>

using namespace std;
using namespace facter::facts;

TEST(facter_facts_collection, default_constructor) {
    collection facts;
    ASSERT_TRUE(facts.empty());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_collection, simple_fact) {
    collection facts;
    facts.add("foo", make_value<string_value>("bar"));
    ASSERT_EQ(1u, facts.size());
    ASSERT_FALSE(facts.empty());
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
    virtual void resolve_facts(collection& facts)
    {
        facts.add("foo", make_value<string_value>("bar"));
    }
};

TEST(facter_facts_collection, simple_resolver) {
    collection facts;
    facts.add(make_shared<simple_resolver>());
    ASSERT_FALSE(facts.empty());
    ASSERT_EQ(1u, facts.size());
    ASSERT_EQ("bar", facts.get<string_value>("foo")->value());
}

struct multi_resolver : resolver
{
    multi_resolver() : resolver("test", { "foo", "bar" })
    {
    }

 protected:
    virtual void resolve_facts(collection& facts)
    {
        facts.add("foo", make_value<string_value>("bar"));
        facts.add("bar", make_value<string_value>("foo"));
    }
};

TEST(facter_facts_collection, resolve_specific) {
    collection facts;
    facts.add(make_shared<multi_resolver>());
    ASSERT_EQ(2u, facts.size());
    ASSERT_FALSE(facts.empty());
    facts.filter({ "bar" });
    ASSERT_EQ(1u, facts.size());
    ASSERT_EQ(nullptr, facts.get<string_value>("foo"));
    ASSERT_EQ("foo", facts.get<string_value>("bar")->value());
}

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

TEST(facter_facts_collection, each) {
    collection facts;
    facts.add(make_shared<multi_resolver>());
    size_t count = 0;
    bool failed_foo = true;
    bool failed_bar = true;
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

TEST(facter_facts_collection, write_json) {
    collection facts;
    facts.add(make_shared<multi_resolver>());
    ostringstream ss;
    facts.write(ss, format::json);
    ASSERT_EQ("{\n  \"bar\": \"foo\",\n  \"foo\": \"bar\"\n}", ss.str());
}

TEST(facter_facts_collection, write_yaml) {
    collection facts;
    facts.add(make_shared<multi_resolver>());
    ostringstream ss;
    facts.write(ss, format::yaml);
    ASSERT_EQ("bar: \"foo\"\nfoo: \"bar\"", ss.str());
}

TEST(facter_facts_collection, write_hash) {
    collection facts;
    facts.add(make_shared<multi_resolver>());
    ostringstream ss;
    facts.write(ss, format::hash);
    ASSERT_EQ("bar => foo\nfoo => bar", ss.str());
}

TEST(facter_facts_collection, insertion_operator_simple) {
    collection facts;
    facts.add(make_shared<simple_resolver>());
    ostringstream ss;
    facts.write(ss);
    ASSERT_EQ("bar", ss.str());
}
