#include <gmock/gmock.h>
#include <facter/facts/integer_value.hpp>
#include <rapidjson/document.h>
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace rapidjson;

TEST(facter_facts_integer_value, integer_constructor) {
    // small integer
    integer_value foo(42);
    ASSERT_EQ(42, foo.value());

    // very large integer but in range
    int64_t large_int = 1LL << 62;
    integer_value foo3(large_int);
    ASSERT_EQ(4611686018427387904LL, foo3.value());
}

TEST(facter_facts_integer_value, string_constructor) {
    // string integer
    integer_value foo("42");
    ASSERT_EQ(42, foo.value());

    // very large integer string
    integer_value foo4("4611686018427387904");
    ASSERT_EQ(4611686018427387904LL, foo4.value());

    // string not-an-integer
    // TODO: expect a warning log message
    integer_value not_an_integer("i am not an integer");
    ASSERT_EQ(0, not_an_integer.value());
}

TEST(facter_facts_integer_value, to_json) {
    integer_value value(1337);

    Value json_value;
    MemoryPoolAllocator<> allocator;
    value.to_json(allocator, json_value);
    ASSERT_TRUE(json_value.IsNumber());
    ASSERT_EQ(1337, json_value.GetInt64());
}

TEST(facter_facts_integer_value, insertion_operator) {
    integer_value value(5);

    ostringstream stream;
    stream << value;
    ASSERT_EQ("5", stream.str());
}
