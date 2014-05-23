#include <gmock/gmock.h>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

TEST(facter_facts_double_value, constructor) {
    double_value foo(42.0);
    ASSERT_DOUBLE_EQ(42.0, foo.value());
}

TEST(facter_facts_double_value, to_json) {
    double_value value(1337.1337);

    rapidjson::Value json_value;
    MemoryPoolAllocator<> allocator;
    value.to_json(allocator, json_value);
    ASSERT_TRUE(json_value.IsNumber());
    ASSERT_DOUBLE_EQ(1337.1337, json_value.GetDouble());
}

TEST(facter_facts_double_value, insertion_operator) {
    double_value value(123.456);

    ostringstream stream;
    stream << value;
    ASSERT_EQ("123.456", stream.str());
}

TEST(facter_facts_double_value, yaml_insertion_operator) {
    double_value value(123.456);

    Emitter emitter;
    emitter << value;
    ASSERT_EQ("123.456", string(emitter.c_str()));
}
