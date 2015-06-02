#include <catch.hpp>
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

SCENARIO("using a map fact value") {
    map_value value;
    REQUIRE(value.empty());
    GIVEN("a null value to add") {
        value.add("key", nullptr);
        THEN("it should still be empty") {
            REQUIRE(value.empty());
        }
    }
    GIVEN("elements to insert") {
        value.add("string", make_value<string_value>("hello"));
        value.add("integer", make_value<integer_value>(5));
        auto array_element = make_value<array_value>();
        array_element->add(make_value<string_value>("1"));
        array_element->add(make_value<integer_value>(2));
        value.add("array", move(array_element));
        auto map_element = make_value<map_value>();
        map_element->add("foo", make_value<string_value>("bar"));
        value.add("map", move(map_element));

        THEN("it should contain the elements that were added") {
            REQUIRE(value.size() == 4u);
            auto str = value.get<string_value>("string");
            REQUIRE(str);
            REQUIRE(str->value() == "hello");

            auto integer = value.get<integer_value>("integer");
            REQUIRE(integer);
            REQUIRE(integer->value() == 5);

            auto array = value.get<array_value>("array");
            REQUIRE(array);
            REQUIRE(array->size() == 2u);
            str = array->get<string_value>(0);
            REQUIRE(str);
            REQUIRE(str->value() == "1");
            integer = array->get<integer_value>(1);
            REQUIRE(integer);
            REQUIRE(integer->value() == 2);

            auto mapval = value.get<map_value>("map");
            REQUIRE(mapval);
            REQUIRE(mapval->size() == 1u);
            str = mapval->get<string_value>("foo");
            REQUIRE(str);
            REQUIRE(str->value() == "bar");
        }
        THEN("elements should be in sort order") {
            int index = 0;
            value.each([&](string const& name, struct value const* val) {
                if (index == 0) {
                    REQUIRE(name == "array");
                } else if (index == 1) {
                    REQUIRE(name == "integer");
                } else if (index == 2) {
                    REQUIRE(name == "map");
                } else if (index == 3) {
                    REQUIRE(name == "string");
                } else {
                    FAIL("should not be reached");
                    return false;
                }
                ++index;
                return true;
            });
        }
        WHEN("serialized to JSON") {
            THEN("it should contain the same values") {
                rapidjson::Value json_value;
                MemoryPoolAllocator<> allocator;
                value.to_json(allocator, json_value);
                REQUIRE(json_value.IsObject());
                REQUIRE(json_value["string"].IsString());
                REQUIRE(string(json_value["string"].GetString()) == "hello");
                REQUIRE(json_value["integer"].IsNumber());
                REQUIRE(json_value["integer"].GetInt64() == 5);
                REQUIRE(json_value["array"].IsArray());
                REQUIRE(json_value["array"].Size() == 2);
                REQUIRE(json_value["array"][0u].IsString());
                REQUIRE(string(json_value["array"][0u].GetString()) == "1");
                REQUIRE(json_value["array"][1u].IsNumber());
                REQUIRE(json_value["array"][1u].GetInt64() == 2);
                REQUIRE(json_value["map"].IsObject());
                REQUIRE(json_value["map"]["foo"].IsString());
                REQUIRE(string(json_value["map"]["foo"].GetString()) == "bar");
            }
        }
        WHEN("serialized to text") {
            THEN("it should contain the same values") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "{\n  array => [\n    \"1\",\n    2\n  ],\n  integer => 5,\n  map => {\n    foo => \"bar\"\n  },\n  string => \"hello\"\n}");
            }
        }
        WHEN("serialized to text") {
            THEN("it should contain the same values") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "array:\n  - \"1\"\n  - 2\ninteger: 5\nmap:\n  foo: bar\nstring: hello");
            }
        }
    }
}
