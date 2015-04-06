#include <catch.hpp>
#include <facter/util/directory.hpp>
#include <boost/filesystem.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::util;
using namespace facter::testing;

SCENARIO("listing files in a directory") {
    vector<string> files;
    GIVEN("no pattern") {
        directory::each_file(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls", [&](string const& file) {
            files.push_back(boost::filesystem::path(file).filename().string());
            return true;
        });
        sort(files.begin(), files.end());
        THEN("all files are returned") {
            REQUIRE(files.size() == 4);
            REQUIRE(files[0] == "file1.txt");
            REQUIRE(files[1] == "file2.txt");
            REQUIRE(files[2] == "file3.txt");
            REQUIRE(files[3] == "file4.txt");
        }
    }
    GIVEN("a file pattern") {
        directory::each_file(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls", [&](string const& file) {
            files.push_back(boost::filesystem::path(file).filename().string());
            return true;
        }, "^file[23].txt$");
        sort(files.begin(), files.end());
        THEN("only the matching files are returned") {
            REQUIRE(files.size() == 2);
            REQUIRE(files[0] == "file2.txt");
            REQUIRE(files[1] == "file3.txt");
        }
    }
    GIVEN("a callback that returns false") {
        directory::each_file(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls", [&](string const& file) {
            files.push_back(boost::filesystem::path(file).filename().string());
            return false;
        });
        THEN("only one file is returned") {
            REQUIRE(files.size() == 1);
        }
    }
}

SCENARIO("listing directories in a directory") {
    vector<string> subdirectories;
    GIVEN("no pattern") {
        directory::each_subdirectory(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external", [&](string const& directory) {
            subdirectories.push_back(boost::filesystem::path(directory).filename().string());
            return true;
        });
        sort(subdirectories.begin(), subdirectories.end());
        THEN("all directories are returned") {
            REQUIRE(subdirectories.size() == 6);
            REQUIRE(subdirectories[0] == "json");
            REQUIRE(subdirectories[1] == "ordering");
            REQUIRE(subdirectories[2] == "posix");
            REQUIRE(subdirectories[3] == "text");
            REQUIRE(subdirectories[4] == "windows");
            REQUIRE(subdirectories[5] == "yaml");
        }
    }
    GIVEN("a directory pattern") {
        directory::each_subdirectory(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external", [&](string const& directory) {
            subdirectories.push_back(boost::filesystem::path(directory).filename().string());
            return true;
        }, "^[jy].*$");
        sort(subdirectories.begin(), subdirectories.end());
        THEN("only the matching directories are returned") {
            REQUIRE(subdirectories.size() == 2);
            REQUIRE(subdirectories[0] == "json");
            REQUIRE(subdirectories[1] == "yaml");
        }
    }
    GIVEN("a callback that returns false") {
        directory::each_subdirectory(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external", [&](string const& directory) {
            subdirectories.push_back(boost::filesystem::path(directory).filename().string());
            return false;
        });
        THEN("only one directory is returned") {
            REQUIRE(subdirectories.size() == 1);
        }
    }
}
