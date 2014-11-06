#include <gmock/gmock.h>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

TEST(facter_facts_map_value, default_constructor) {
    map_value value;
    ASSERT_EQ(0u, value.size());
}

TEST(facter_facts_map_value, null_add) {
    map_value value;
    value.add("null", nullptr);
    ASSERT_EQ(0u, value.size());
}

TEST(facter_facts_map_value, map_constructor) {
    map_value value;
    value.add("string", make_value<string_value>("hello"));
    value.add("integer", make_value<integer_value>(5));

    auto array_element = make_value<array_value>();
    array_element->add(make_value<string_value>("1"));
    array_element->add(make_value<integer_value>(2));
    value.add("array", move(array_element));

    auto map_element = make_value<map_value>();
    map_element->add("foo", make_value<string_value>("bar"));
    value.add("map", move(map_element));

    ASSERT_EQ(4u, value.size());

    auto str = value.get<string_value>("string");
    ASSERT_NE(nullptr, str);
    ASSERT_EQ("hello", str->value());

    auto integer = value.get<integer_value>("integer");
    ASSERT_NE(nullptr, integer);
    ASSERT_EQ(5, integer->value());

    auto array = value.get<array_value>("array");
    ASSERT_NE(nullptr, array);
    ASSERT_EQ(2u, array->size());
    str = array->get<string_value>(0);
    ASSERT_EQ("1", str->value());
    integer = array->get<integer_value>(1);
    ASSERT_EQ(2u, integer->value());

    auto mapval = value.get<map_value>("map");
    ASSERT_NE(nullptr, mapval);
    ASSERT_EQ(1u, mapval->size());
    str = mapval->get<string_value>("foo");
    ASSERT_NE(nullptr, str);
    ASSERT_EQ("bar", str->value());
}

TEST(facter_facts_map_value, each) {
    map_value value;
    value.add("fact1", make_value<string_value>("1"));
    value.add("fact2", make_value<string_value>("2"));
    value.add("fact3", make_value<string_value>("3"));

    size_t count = 0;
    bool failed = false;
    value.each([&](string const& name, struct value const* val) {
        auto string_val = dynamic_cast<string_value const*>(val);
        if (!string_val) {
            failed = true;
            return false;
        }
        if ((name == "fact1" && string_val->value() != "1") ||
            (name == "fact2" && string_val->value() != "2") ||
            (name == "fact3" && string_val->value() != "3")) {
            failed = true;
            return false;
        }
        ++count;
        return true;
    });
    ASSERT_FALSE(failed);
    ASSERT_EQ(3u, count);
}

TEST(facter_facts_map_value, to_json) {
    map_value value;
    value.add("string", make_value<string_value>("hello"));
    value.add("integer", make_value<integer_value>(5));

    auto array_element = make_value<array_value>();
    array_element->add(make_value<string_value>("1"));
    array_element->add(make_value<integer_value>(2));
    value.add("array", move(array_element));

    auto map_element = make_value<map_value>();
    map_element->add("foo", make_value<string_value>("bar"));
    value.add("map", move(map_element));

    rapidjson::Value json_value;
    MemoryPoolAllocator<> allocator;
    value.to_json(allocator, json_value);
    ASSERT_TRUE(json_value.IsObject());

    ASSERT_TRUE(json_value["string"].IsString());
    ASSERT_EQ("hello", string(json_value["string"].GetString()));

    ASSERT_TRUE(json_value["integer"].IsNumber());
    ASSERT_EQ(5ll, json_value["integer"].GetInt64());

    ASSERT_TRUE(json_value["array"].IsArray());
    ASSERT_EQ(2u, json_value["array"].Size());
    ASSERT_TRUE(json_value["array"][0u].IsString());
    ASSERT_EQ("1", string(json_value["array"][0u].GetString()));
    ASSERT_TRUE(json_value["array"][1u].IsNumber());
    ASSERT_EQ(2ll, json_value["array"][1u].GetInt64());

    ASSERT_TRUE(json_value["map"].IsObject());
    ASSERT_TRUE(json_value["map"]["foo"].IsString());
    ASSERT_EQ("bar", string(json_value["map"]["foo"].GetString()));
}

TEST(facter_facts_map_value, write_stream) {
    map_value value;
    value.add("string", make_value<string_value>("hello"));
    value.add("integer", make_value<integer_value>(5));

    auto array_element = make_value<array_value>();
    array_element->add(make_value<string_value>("1"));
    array_element->add(make_value<integer_value>(2));
    value.add("array", move(array_element));

    auto map_element = make_value<map_value>();
    map_element->add("foo", make_value<string_value>("bar"));
    value.add("map", move(map_element));

    ostringstream stream;
    value.write(stream);
    ASSERT_EQ("{\n  array => [\n    \"1\",\n    2\n  ],\n  integer => 5,\n  map => {\n    foo => \"bar\"\n  },\n  string => \"hello\"\n}", stream.str());
}

TEST(facter_facts_map_value, write_yaml) {
    map_value value;
    value.add("string", make_value<string_value>("hello"));
    value.add("integer", make_value<integer_value>(5));

    auto array_element = make_value<array_value>();
    array_element->add(make_value<string_value>("1"));
    array_element->add(make_value<integer_value>(2));
    value.add("array", move(array_element));

    auto map_element = make_value<map_value>();
    map_element->add("foo", make_value<string_value>("bar"));
    value.add("map", move(map_element));

    Emitter emitter;
    value.write(emitter);
    ASSERT_EQ("array:\n  - \"1\"\n  - 2\ninteger: 5\nmap:\n  foo: bar\nstring: hello", string(emitter.c_str()));
}
