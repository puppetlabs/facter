#include <catch.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>
#include <cmath>
#include <limits>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

SCENARIO("using a double fact value") {
    double_value value(42.4242);
    REQUIRE(value.value() == Approx(42.4242));
    WHEN("serialized to JSON") {
        THEN("it should have the same value") {
            json_value json;
            json_allocator allocator;
            value.to_json(allocator, json);
            REQUIRE(json.IsNumber());
            REQUIRE(json.GetDouble() == Approx(42.4242));
        }
    }
    WHEN("serialized to YAML") {
        THEN("it should have the same value") {
            Emitter emitter;
            value.write(emitter);
            REQUIRE(string(emitter.c_str()) == "42.4242");
        }
    }
    WHEN("serialized to text") {
        THEN("it should have the same value") {
            ostringstream stream;
            value.write(stream);
            REQUIRE(stream.str() == "42.4242");
        }
    }
}
