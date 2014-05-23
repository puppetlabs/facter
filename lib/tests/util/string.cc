#include <gmock/gmock.h>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;
using testing::ElementsAre;

TEST(facter_util_string, starts_with) {
    ASSERT_FALSE(starts_with("hello", "world"));
    ASSERT_TRUE(starts_with("hello world", "hello"));
    ASSERT_FALSE(starts_with("", "hello"));
    ASSERT_TRUE(starts_with("", ""));
    ASSERT_TRUE(starts_with("hello", ""));
}

TEST(facter_util_string, ends_with) {
    ASSERT_TRUE(ends_with("hello world", "world"));
    ASSERT_FALSE(ends_with("hello world", "hello"));
    ASSERT_TRUE(ends_with("hello world", ""));
    ASSERT_TRUE(ends_with("", ""));
    ASSERT_TRUE(ends_with("hello", ""));
}

TEST(facter_util_string, ltrim) {
    ASSERT_EQ("", ltrim(""));
    ASSERT_EQ("hello world", ltrim("   hello world"));
    ASSERT_EQ("hello world   ", ltrim("   hello world   "));
    ASSERT_EQ("hello world", ltrim("hello world"));
    ASSERT_EQ("hello world", ltrim("???hello world", { '?' }));
    ASSERT_EQ("hello world?!!", ltrim("?!?hello world?!!", { '?', '!' }));
    ASSERT_EQ("   hello world   ", ltrim("   hello world   ", { }));
}

TEST(facter_util_string, rtrim) {
    ASSERT_EQ("", rtrim(""));
    ASSERT_EQ("hello world", rtrim("hello world   "));
    ASSERT_EQ("   hello world", rtrim("   hello world   "));
    ASSERT_EQ("hello world", rtrim("hello world"));
    ASSERT_EQ("hello world", rtrim("hello world???", { '?' }));
    ASSERT_EQ("?!?hello world", rtrim("?!?hello world?!!", { '?', '!' }));
    ASSERT_EQ("   hello world   ", rtrim("   hello world   ", { }));
}

TEST(facter_util_string, trim) {
    ASSERT_EQ("", trim(""));
    ASSERT_EQ("hello world", trim("   hello world   "));
    ASSERT_EQ("hello world", trim("   hello world"));
    ASSERT_EQ("hello world", trim("hello world   "));
    ASSERT_EQ("hello world", trim("hello world"));
    ASSERT_EQ("hello world", trim("hello world???", { '?' }));
    ASSERT_EQ("hello world", trim("?!?hello world?!!", { '?', '!' }));
    ASSERT_EQ("   hello world   ", trim("   hello world   ", { }));
}

TEST(facter_util_string, tokenize) {
    ASSERT_THAT(tokenize("hello world"), ElementsAre("hello", "world"));
    ASSERT_THAT(tokenize("  hello      world !  "), ElementsAre("hello", "world", "!"));
    ASSERT_EQ(0u, tokenize("").size());
}

TEST(facter_util_string, split) {
    ASSERT_THAT(split("hello world"), ElementsAre("hello", "world"));
    ASSERT_THAT(split("  hello      world !  "), ElementsAre("hello", "world", "!"));
    ASSERT_THAT(split("xhelloxworldx!x", 'x'), ElementsAre("hello", "world", "!"));
    ASSERT_THAT(split("xhello x worldx!x", 'x'), ElementsAre("hello ", " world", "!"));
    ASSERT_EQ(0u, split("").size());
}

TEST(facter_util_string, join) {
    ASSERT_EQ("hello world", join({"hello", "world"}));
    ASSERT_EQ("hello world", join({"hello", "world"}, " "));
    ASSERT_EQ("foo!!!bar!!!baz", join({"foo", "bar", "baz"}, "!!!"));
    ASSERT_EQ("", join({""}, "!!"));
    ASSERT_EQ("!!", join({"", ""}, "!!"));
    ASSERT_EQ("", join({}, " "));
}

TEST(facter_util_string, to_lower) {
    ASSERT_EQ("hello world!", to_lower("Hello World!"));
    ASSERT_EQ("hello world!", to_lower("HELLO WORLD!"));
    ASSERT_EQ("hello world!", to_lower("hello world!"));
    ASSERT_EQ("", to_lower(""));
}

TEST(facter_util_string, to_upper) {
    ASSERT_EQ("HELLO WORLD!", to_upper("hELLO wORLD!"));
    ASSERT_EQ("HELLO WORLD!", to_upper("hello world!"));
    ASSERT_EQ("HELLO WORLD!", to_upper("HELLO WORLD!"));
    ASSERT_EQ("", to_upper(""));
}

TEST(facter_util_string, to_hex) {
    uint8_t buffer[] = { 0xBA, 0xAD, 0xF0, 0x0D };
    ASSERT_EQ("BAADF00D", to_hex(buffer, sizeof(buffer), true));
    ASSERT_EQ("baadf00d", to_hex(buffer, sizeof(buffer)));
    ASSERT_EQ("", to_hex(nullptr, 0));
    ASSERT_EQ("", to_hex(buffer, 0));
}

TEST(facter_util_string, ci_string) {
    ASSERT_EQ("hello world!", ci_string("HELLO WORLD!"));
    ASSERT_EQ("HELLO world!", ci_string("hello WORLD!"));
    ASSERT_EQ("hello WORLD!", ci_string("HELLO world!"));
    ASSERT_NE("not hello WORLD!", ci_string("hello WORLD!"));
    ASSERT_EQ("", ci_string(""));
}

TEST(facter_util_string, each_line) {
    size_t count = 0;
    bool failed = false;
    each_line("line1\nline2\nline3", [&](string const& line) {
        if ((count == 0 && line != "line1") ||
            (count == 1 && line != "line2") ||
            (count == 2 && line != "line3")) {
            failed = true;
            return false;
        }
        ++count;
        return true;
    });
    ASSERT_FALSE(failed);
    ASSERT_EQ(3u, count);
}
