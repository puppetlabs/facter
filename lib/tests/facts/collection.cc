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

struct simple_resolver : facter::facts::resolver
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

struct multi_resolver : facter::facts::resolver
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
    facts.write(ss, format::hash, { "foo" });
    ASSERT_EQ("bar", ss.str());
}

TEST(facter_facts_collection, resolve_external) {
    collection facts;
    ASSERT_EQ(0u, facts.size());
    ASSERT_TRUE(facts.empty());
    facts.add_external_facts({
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json",
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text",
    });
    ASSERT_FALSE(facts.empty());
    ASSERT_EQ(17u, facts.size());
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
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact1"));
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact2"));
    ASSERT_EQ(nullptr, facts.get<string_value>("txt_fact3"));
    ASSERT_NE(nullptr, facts.get<string_value>("txt_fact4"));
}

TEST(facter_facts_collection, query) {
    collection facts;

    auto map = make_value<map_value>();
    map->add("string", make_value<string_value>("hello"));
    map->add("integer", make_value<integer_value>(5));
    map->add("double", make_value<double_value>(0.3));
    map->add("boolean", make_value<boolean_value>(true));

    auto submap = make_value<map_value>();
    submap->add("foo", make_value<string_value>("bar"));
    map->add("submap", move(submap));

    submap = make_value<map_value>();
    submap->add("jam", make_value<string_value>("cakes"));
    map->add("name.with.dots", move(submap));

    auto array = make_value<array_value>();
    array->add(make_value<string_value>("foo"));
    array->add(make_value<integer_value>(10));
    array->add(make_value<double_value>(2.3));
    array->add(make_value<boolean_value>(false));

    submap = make_value<map_value>();
    submap->add("bar", make_value<string_value>("baz"));
    array->add(move(submap));
    map->add("array", move(array));

    facts.add("map", move(map));
    facts.add("string", make_value<string_value>("world"));

    auto mvalue = facts.query<map_value>("map");
    ASSERT_NE(nullptr, mvalue);
    ASSERT_EQ(7u, mvalue->size());

    auto svalue = facts.query<string_value>("map.string");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("hello", svalue->value());

    auto ivalue = facts.query<integer_value>("map.integer");
    ASSERT_NE(nullptr, ivalue);
    ASSERT_EQ(5, ivalue->value());

    auto dvalue = facts.query<double_value>("map.double");
    ASSERT_NE(nullptr, dvalue);
    ASSERT_EQ(0.3, dvalue->value());

    auto bvalue = facts.query<boolean_value>("map.boolean");
    ASSERT_NE(nullptr, bvalue);
    ASSERT_TRUE(bvalue->value());

    mvalue = facts.query<map_value>("map.submap");
    ASSERT_NE(nullptr, mvalue);
    ASSERT_EQ(1u, mvalue->size());

    svalue = facts.query<string_value>("map.submap.foo");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("bar", svalue->value());

    auto avalue = facts.query<array_value>("map.array");
    ASSERT_NE(nullptr, avalue);
    ASSERT_EQ(5u, avalue->size());

    svalue = facts.query<string_value>("map.array.0");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("foo", svalue->value());

    ivalue = facts.query<integer_value>("map.array.1");
    ASSERT_NE(nullptr, ivalue);
    ASSERT_EQ(10, ivalue->value());

    dvalue = facts.query<double_value>("map.array.2");
    ASSERT_NE(nullptr, dvalue);
    ASSERT_EQ(2.3, dvalue->value());

    bvalue = facts.query<boolean_value>("map.array.3");
    ASSERT_NE(nullptr, bvalue);
    ASSERT_FALSE(bvalue->value());

    mvalue = facts.query<map_value>("map.array.4");
    ASSERT_NE(nullptr, mvalue);
    ASSERT_EQ(1u, mvalue->size());

    svalue = facts.query<string_value>("map.array.4.bar");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("baz", svalue->value());

    auto value = facts.query("map.array.foo");
    ASSERT_EQ(nullptr, value);

    value = facts.query("map.array.5");
    ASSERT_EQ(nullptr, value);

    svalue = facts.query<string_value>("string");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("world", svalue->value());

    value = facts.query("map.name.with.dots");
    ASSERT_EQ(nullptr, value);

    svalue = facts.query<string_value>("map.\"name.with.dots\".jam");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("cakes", svalue->value());
}
