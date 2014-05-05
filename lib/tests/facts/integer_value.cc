#include <gmock/gmock.h>
#include <facter/facts/integer_value.hpp>

using namespace facter::facts;

TEST(facter_facts_integer_value, to_string) {
    // small integer
    integer_value foo(42);
    ASSERT_EQ("42", foo.to_string());

    // very large integer but in range
    int64_t large_int = 1LL << 62;
    integer_value large_int_value(large_int);
    ASSERT_EQ("4611686018427387904", large_int_value.to_string());
}

TEST(facter_facts_integer_value, string_constructor) {
    // string integer
    integer_value foo("42");
    ASSERT_EQ(42, foo.value());

    // string not-an-integer
    // TODO: expect a warning log message
    integer_value not_an_integer("i am not an integer");
    ASSERT_EQ(0, not_an_integer.value());
}
