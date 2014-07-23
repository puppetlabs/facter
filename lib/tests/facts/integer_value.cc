#include <gmock/gmock.h>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

TEST(facter_facts_integer_value, constructor) {
    // small integer
    integer_value foo(42);
    ASSERT_EQ(42, foo.value());

    // very large integer but in range
    int64_t large_int = 1LL << 62;
    integer_value foo3(large_int);
    ASSERT_EQ(4611686018427387904LL, foo3.value());
}

TEST(facter_facts_integer_value, to_json) {
    integer_value value(1337);

    rapidjson::Value json_value;
    MemoryPoolAllocator<> allocator;
    value.to_json(allocator, json_value);
    ASSERT_TRUE(json_value.IsNumber());
    ASSERT_EQ(1337, json_value.GetInt64());
}

TEST(facter_facts_integer_value, write_stream) {
    integer_value value(5);

    ostringstream stream;
    value.write(stream);
    ASSERT_EQ("5", stream.str());
}

TEST(facter_facts_integer_value, write_yaml) {
    integer_value value(5);

    Emitter emitter;
    value.write(emitter);
    ASSERT_EQ("5", string(emitter.c_str()));
}
