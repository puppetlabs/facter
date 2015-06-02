#include <catch.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

SCENARIO("using an array fact value") {
    array_value value;
    REQUIRE(value.empty());
    GIVEN("a null value to add") {
        value.add(nullptr);
        THEN("it should still be empty") {
            REQUIRE(value.empty());
        }
    }
    GIVEN("an out of range index") {
        THEN("get() raises out_of_range") {
            REQUIRE_THROWS_AS(value.get<string_value>(0), std::out_of_range);
        }
        THEN("operator[] returns nullptr") {
            REQUIRE_FALSE(value[42]);
        }
    }
    GIVEN("a string value to add") {
        value.add(make_value<string_value>("hello"));
        THEN("it should contain the string value") {
            REQUIRE_FALSE(value.empty());
            REQUIRE(value.size() == 1u);
            REQUIRE(value.get<string_value>(0));
            REQUIRE(value.get<string_value>(0)->value() == "hello");
        }
    }
    GIVEN("an integer value to add") {
        value.add(make_value<integer_value>(123));
        THEN("it should contain the string value") {
            REQUIRE_FALSE(value.empty());
            REQUIRE(value.size() == 1u);
            REQUIRE(value.get<integer_value>(0));
            REQUIRE(value.get<integer_value>(0)->value() == 123);
        }
    }
    GIVEN("multiple values to add") {
        auto subarray = make_value<array_value>();
        subarray->add(make_value<string_value>("element"));
        value.add(make_value<string_value>("1"));
        value.add(make_value<integer_value>(2));
        value.add(move(subarray));
        THEN("it should contain the values in order they were added") {
            REQUIRE(value.size() == 3u);
            auto string_val = value.get<string_value>(0);
            REQUIRE(string_val);
            REQUIRE(string_val->value() == "1");
            auto int_val = value.get<integer_value>(1);
            REQUIRE(int_val);
            REQUIRE(int_val->value() == 2);
            auto subarray = value.get<array_value>(2);
            REQUIRE(subarray);
            REQUIRE(subarray->size() == 1u);
            string_val = subarray->get<string_value>(0);
            REQUIRE(string_val);
            REQUIRE(string_val->value() == "element");
        }
        THEN("each is enumerated in order") {
            size_t index = 0u;
            value.each([&](struct value const* val) {
                if (index == 0u) {
                    auto string_val = dynamic_cast<string_value const*>(val);
                    REQUIRE(string_val);
                    REQUIRE(string_val->value() == "1");
                } else if (index == 1u) {
                    auto int_val = dynamic_cast<integer_value const*>(val);
                    REQUIRE(int_val);
                    REQUIRE(int_val->value() == 2);
                } else if (index == 2u) {
                    auto subarray = dynamic_cast<array_value const*>(val);
                    REQUIRE(subarray);
                    REQUIRE(subarray->size() == 1u);
                    auto string_val = subarray->get<string_value>(0);
                    REQUIRE(string_val);
                    REQUIRE(string_val->value() == "element");
                } else {
                    FAIL("should not be reached");
                }
                ++index;
                return true;
            });
            REQUIRE(index == value.size());
        }
        WHEN("serialized to JSON") {
            THEN("it should contain the same values") {
                rapidjson::Value json_value;
                MemoryPoolAllocator<> allocator;
                value.to_json(allocator, json_value);
                REQUIRE(json_value.IsArray());
                REQUIRE(json_value.Size() == 3);
                REQUIRE(json_value[0u].IsString());
                REQUIRE(string(json_value[0u].GetString()) == "1");
                REQUIRE(json_value[1u].IsNumber());
                REQUIRE(json_value[1u].GetInt64() == 2ll);
                REQUIRE(json_value[2u].IsArray());
                REQUIRE(json_value[2u].Size() == 1);
                REQUIRE(json_value[2u][0u].IsString());
                REQUIRE(string(json_value[2u][0u].GetString()) == "element");
            }
        }
        WHEN("serialized to text") {
            THEN("it should contain the same values") {
                ostringstream stream;
                value.write(stream);
                REQUIRE(stream.str() == "[\n  \"1\",\n  2,\n  [\n    \"element\"\n  ]\n]");
            }
        }
        WHEN("serialized to YAML") {
            THEN("it should contain the same values") {
                Emitter emitter;
                value.write(emitter);
                REQUIRE(string(emitter.c_str()) == "- \"1\"\n- 2\n-\n  - element");
            }
        }
    }
    GIVEN("each with a callback that returns false") {
        THEN("it should stop enumerating") {
            value.add(make_value<integer_value>(1));
            value.add(make_value<integer_value>(2));
            value.add(make_value<integer_value>(3));
            size_t index = 0u;
            value.each([&](struct value const* val) {
                ++index;
                return false;
            });
            REQUIRE(index == 1u);
        }
    }
}
