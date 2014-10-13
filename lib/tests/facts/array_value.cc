#include <gmock/gmock.h>
#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;
using namespace YAML;

TEST(facter_facts_array_value, default_constructor) {
    array_value value;
    ASSERT_EQ(0u, value.size());
}

TEST(facter_facts_array_value, null_add) {
    array_value value;
    value.add(nullptr);
    ASSERT_EQ(0u, value.size());
}

TEST(facter_facts_array_value, vector_constructor) {
    auto subarray = make_value<array_value>();
    subarray->add(make_value<string_value>("child"));

    array_value value;
    value.add(make_value<string_value>("1"));
    value.add(make_value<integer_value>(2));
    value.add(move(subarray));
    ASSERT_EQ(3u, value.size());

    auto str = value.get<string_value>(0);
    ASSERT_NE(nullptr, str);
    ASSERT_EQ("1", str->value());

    auto integer = value.get<integer_value>(1);
    ASSERT_NE(nullptr, integer);
    ASSERT_EQ(2, integer->value());

    auto array = value.get<array_value>(2);
    ASSERT_NE(nullptr, array);
    ASSERT_EQ(1u, array->size());

    str = array->get<string_value>(0);
    ASSERT_NE(nullptr, str);
    ASSERT_EQ("child", str->value());
}

TEST(facter_facts_array_value, each) {
    array_value value;
    value.add(make_value<string_value>("1"));
    value.add(make_value<string_value>("2"));
    value.add(make_value<string_value>("3"));

    size_t count = 0;
    bool failed = false;
    value.each([&](struct value const* val) {
        auto string_val = dynamic_cast<string_value const*>(val);
        if (!string_val) {
            failed = true;
            return false;
        }
        if ((count == 0 && string_val->value() != "1") ||
            (count == 1 && string_val->value() != "2") ||
            (count == 2 && string_val->value() != "3")) {
            failed = true;
            return false;
        }
        ++count;
        return true;
    });
    ASSERT_FALSE(failed);
    ASSERT_EQ(3u, count);
}

TEST(facter_facts_array_value, to_json) {
    auto subarray = make_value<array_value>();
    subarray->add(make_value<string_value>("child"));

    array_value value;
    value.add(make_value<string_value>("1"));
    value.add(make_value<integer_value>(2));
    value.add(move(subarray));

    rapidjson::Value json_value;
    MemoryPoolAllocator<> allocator;
    value.to_json(allocator, json_value);
    ASSERT_TRUE(json_value.IsArray());
    ASSERT_EQ(3u, json_value.Size());

    ASSERT_TRUE(json_value[0u].IsString());
    ASSERT_EQ("1", string(json_value[0u].GetString()));

    ASSERT_TRUE(json_value[1u].IsNumber());
    ASSERT_EQ(2ll, json_value[1u].GetInt64());

    ASSERT_TRUE(json_value[2u].IsArray());
    ASSERT_EQ(1u, json_value[2u].Size());
    ASSERT_TRUE(json_value[2u][0u].IsString());
    ASSERT_EQ("child", string(json_value[2u][0u].GetString()));
}

TEST(facter_facts_array_value, write_stream) {
    auto subarray = make_value<array_value>();
    subarray->add(make_value<string_value>("child"));

    array_value value;
    value.add(make_value<string_value>("1"));
    value.add(make_value<integer_value>(2));
    value.add(move(subarray));

    ostringstream stream;
    value.write(stream);
    ASSERT_EQ("[\n  \"1\",\n  2,\n  [\n    \"child\"\n  ]\n]", stream.str());
}

TEST(facter_facts_array_value, write_yaml) {
    auto subarray = make_value<array_value>();
    subarray->add(make_value<string_value>("child"));

    array_value value;
    value.add(make_value<string_value>("1"));
    value.add(make_value<integer_value>(2));
    value.add(move(subarray));

    Emitter emitter;
    value.write(emitter);
    ASSERT_EQ("- \"1\"\n- 2\n-\n  - \"child\"", string(emitter.c_str()));
}
