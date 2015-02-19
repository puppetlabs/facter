#include <catch.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

SCENARIO("using a string fact value") {
    GIVEN("a value to copy") {
        string s = "hello world";
        string_value value(s);
        THEN("the value is copied") {
            REQUIRE(s == "hello world");
            REQUIRE(value.value() == "hello world");
        }
    }
    GIVEN("a value to move") {
        string s = "hello world";
        string_value value(std::move(s));
        THEN("the value is moved") {
            REQUIRE(s.empty());
            REQUIRE(value.value() == "hello world");
        }
    }
    GIVEN("a value") {
        string_value value("foobar");
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                rapidjson::Value json_value;
                MemoryPoolAllocator<> allocator;
                value.to_json(allocator, json_value);
                REQUIRE(json_value.IsString());
                REQUIRE(json_value.GetString() == string("foobar"));
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should have the same value") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "foobar");
            }
        }
        WHEN("serialized to text with quotes") {
            THEN("it should be quoted") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "\"foobar\"");
            }
        }
        WHEN("serialized to text without quotes") {
            THEN("it should not be quoted") {
                ostringstream stream;
                value.write(stream, false);
                REQUIRE(stream.str() == "foobar");
            }
        }
    }
}
