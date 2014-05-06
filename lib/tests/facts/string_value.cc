#include <gmock/gmock.h>
#include <facter/facts/string_value.hpp>
#include <rapidjson/document.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;

TEST(facter_facts_string_value, move_constructor) {
    string s = "hello world";
    string_value value(move(s));
    ASSERT_EQ("", s);
    ASSERT_EQ("hello world", value.value());
}

TEST(facter_facts_string_value, copy_constructor) {
    string s = "hello world";
    string_value value(s);
    ASSERT_EQ("hello world", s);
    ASSERT_EQ("hello world", value.value());
}

TEST(facter_facts_string_value, to_json) {
    string_value value("hello world");

    Value json_value;
    MemoryPoolAllocator<> allocator;
    value.to_json(allocator, json_value);
    ASSERT_TRUE(json_value.IsString());
    ASSERT_EQ("hello world", string(json_value.GetString()));
}

TEST(facter_facts_string_value, insertion_operator) {
    string_value value("hello world");

    ostringstream stream;
    stream << value;
    ASSERT_EQ("hello world", stream.str());
}
