#include <catch.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

SCENARIO("using a boolean fact value") {
    GIVEN("true to the constructor") {
        boolean_value value(true);
        REQUIRE(value.value());
        WHEN("serialized to JSON") {
            THEN("it should serialize as true") {
                rapidjson::Value json_value;
                MemoryPoolAllocator<> allocator;
                value.to_json(allocator, json_value);
                REQUIRE(json_value.IsBool());
                REQUIRE(json_value.GetBool());
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should serialize as true") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "true");
            }
        }
        WHEN("serialized to text") {
            THEN("it should serialize to text as true") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "true");
            }
        }
    }
    GIVEN("false to the constructor") {
        boolean_value value(false);
        REQUIRE_FALSE(value.value());
        WHEN("serialized to JSON") {
            THEN("it should serialize as false") {
                rapidjson::Value json_value;
                MemoryPoolAllocator<> allocator;
                value.to_json(allocator, json_value);
                REQUIRE(json_value.IsBool());
                REQUIRE_FALSE(json_value.GetBool());
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should serialize as false") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "false");
            }
        }
        WHEN("serialized to text") {
            THEN("it should serialize to text as false") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "false");
            }
        }
    }
}
