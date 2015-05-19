#include <catch.hpp>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include <boost/algorithm/string.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::util;
using namespace facter::testing;

SCENARIO("reading each line of a file") {
    string fixture_path = "util/multiline_file.txt";
    string fixture_file_path = LIBFACTER_TESTS_DIRECTORY "/fixtures/" + fixture_path;

    string data;
    REQUIRE(load_fixture(fixture_path, data));
    vector<string> fixture_lines;
    boost::split(fixture_lines, data, boost::is_any_of("\n\r"), boost::token_compress_on);

    GIVEN("a file that does not exist") {
        THEN("false is returned") {
            REQUIRE_FALSE(file::each_line("does_not_exist", [](string& line) {
                FAIL("should not be called");
                return true;
            }));
        }
    }
    GIVEN("a callback that returns true") {
        THEN("all lines are returned") {
            vector<string> lines;
            REQUIRE(file::each_line(fixture_file_path, [&](string& line) {
                lines.emplace_back(move(line));
                return true;
            }));
            REQUIRE(lines.size() == 3u);
            REQUIRE(lines == fixture_lines);
        }
    }
    GIVEN("a callback that returns false") {
        THEN("only the first line is returned") {
            vector<string> lines;
            REQUIRE(file::each_line(fixture_file_path, [&](string& line) {
                lines.emplace_back(move(line));
                return false;
            }));
            REQUIRE(lines.size() == 1u);
            REQUIRE(lines[0] == fixture_lines[0]);
        }
    }
}

SCENARIO("reading the entire contents of a file") {
    string fixture_path = "util/multiline_file.txt";
    string fixture_file_path = LIBFACTER_TESTS_DIRECTORY "/fixtures/" + fixture_path;

    GIVEN("a non-existent file") {
        THEN("an empty string is returned") {
            string data;
            REQUIRE(file::read("does_not_exist") == "");
            REQUIRE_FALSE(file::read("does_not_exist", data));
            REQUIRE(data.empty());
            REQUIRE_FALSE(file::read("", data));
            REQUIRE(data.empty());
        }
    }
    GIVEN("an existent file") {
        string fixture;
        REQUIRE(load_fixture(fixture_path, fixture));
        THEN("the contents should be returned") {
            string data;
            REQUIRE(file::read(fixture_file_path) == fixture);
            REQUIRE(file::read(fixture_file_path, data));
            REQUIRE(data == fixture);
        }
    }
}
