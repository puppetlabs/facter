#include <gmock/gmock.h>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::util;
using namespace facter::testing;

TEST(facter_util_file, read) {
    string fixture_path = "util/multiline_file.txt";
    string fixture_file_path = LIBFACTER_TESTS_DIRECTORY "/fixtures/" + fixture_path;

    // Test non-existant file
    string data;
    ASSERT_EQ("", file::read("does_not_exist"));
    ASSERT_EQ("", file::read(""));
    ASSERT_FALSE(file::read("does_not_exist", data));
    ASSERT_FALSE(file::read("", data));

    // Test read
    string fixture;
    ASSERT_TRUE(load_fixture(fixture_path, fixture));
    ASSERT_EQ(fixture, file::read(fixture_file_path));
    ASSERT_TRUE(file::read(fixture_file_path, data));
    ASSERT_EQ(fixture, data);
}

TEST(facter_util_file, read_first_line) {
    string fixture_path = "util/multiline_file.txt";
    string fixture_file_path = LIBFACTER_TESTS_DIRECTORY "/fixtures/" + fixture_path;

    // Test non-existant file
    string data;
    ASSERT_EQ("", file::read_first_line("does_not_exist"));
    ASSERT_EQ("", file::read_first_line(""));
    ASSERT_FALSE(file::read_first_line("does_not_exist", data));
    ASSERT_FALSE(file::read_first_line("", data));

    // Test read
    string fixture;
    ASSERT_TRUE(load_fixture(fixture_path, fixture));

    vector<string> lines = split(fixture, '\n');
    ASSERT_EQ(3u, lines.size());

    ASSERT_EQ(lines[0], file::read_first_line(fixture_file_path));
    ASSERT_TRUE(file::read_first_line(fixture_file_path, data));
    ASSERT_EQ(lines[0], data);
}
