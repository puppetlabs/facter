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

TEST(facter_facts_collection, write_hash_single) {
    collection facts;
    facts.add(make_shared<simple_resolver>());
    ostringstream ss;
    facts.write(ss);
    ASSERT_EQ("bar", ss.str());
}
