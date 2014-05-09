#include <gmock/gmock.h>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::util;
using namespace facter::testing;
using testing::ElementsAre;

TEST(facter_util_file, each_line) {
    string fixture_path = "util/multiline_file.txt";
    string fixture_file_path = LIBFACTER_TESTS_DIRECTORY "/fixtures/" + fixture_path;

    string data;
    ASSERT_TRUE(load_fixture(fixture_path, data));
    vector<string> fixture_lines = split(data, '\n');

    // Ensure there's no carriage returns
     transform(
        fixture_lines.begin(),
        fixture_lines.end(),
        fixture_lines.begin(),
        [](string& s) {
            rtrim(s, { '\r' });
            return s;
        });

    // Test non-existent file
    bool failed = false;
    ASSERT_FALSE(file::each_line("does_not_exist", [&failed](string& line) {
        failed = true;
        return true;
    }));

    if (failed) {
        FAIL();
    }

    // Test all lines
    vector<string> lines;
    ASSERT_TRUE(file::each_line(fixture_file_path, [&lines](string& line) {
        lines.emplace_back(move(line));
        return true;
    }));
    ASSERT_EQ(3u, lines.size());
    ASSERT_THAT(lines, fixture_lines);

    // Test short circuiting
    int count = 0;
    lines.clear();
    ASSERT_TRUE(file::each_line(fixture_file_path, [&lines, &count](string& line) {
        lines.emplace_back(move(line));
        return ++count < 2;
    }));
    ASSERT_EQ(2u, lines.size());
    ASSERT_THAT(lines, ElementsAre(lines[0], lines[1]));
}

TEST(facter_util_file, read) {
    string fixture_path = "util/multiline_file.txt";
    string fixture_file_path = LIBFACTER_TESTS_DIRECTORY "/fixtures/" + fixture_path;

    // Test non-existent file
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

    // Test non-existent file
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
