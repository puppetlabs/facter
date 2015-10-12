#include <catch.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

SCENARIO("using an integer fact value") {
    GIVEN("a small integer value") {
        int expected_value = 42;
        integer_value value(expected_value);
        REQUIRE(value.value() == expected_value);
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsNumber());
                REQUIRE(json.GetInt64() == expected_value);
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should have the same value") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "42");
            }
        }
        WHEN("serialized to text") {
            THEN("it should have the same value") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "42");
            }
        }
    }
    GIVEN("a very large integer value") {
        int64_t expected_value = 1LL << 62;
        integer_value value(expected_value);
        REQUIRE(value.value() == expected_value);
        WHEN("serialized to JSON") {
            THEN("it should have the same value") {
                json_value json;
                json_allocator allocator;
                value.to_json(allocator, json);
                REQUIRE(json.IsNumber());
                REQUIRE(json.GetInt64() == expected_value);
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should have the same value") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "4611686018427387904");
            }
        }
        WHEN("serialized to text") {
            THEN("it should have the same value") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "4611686018427387904");
            }
        }
    }
}
