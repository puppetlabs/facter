#include <gmock/gmock.h>
#include <facter/util/directory.hpp>
#include <boost/filesystem.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::util;
using namespace facter::testing;
using testing::ElementsAre;

TEST(facter_util_directory, each_file) {
    vector<string> files;

    directory::each_file(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls", [&](string const& file) {
        files.push_back(boost::filesystem::path(file).filename().string());
        return true;
    });

    sort(files.begin(), files.end());

    ASSERT_THAT(files, ElementsAre("file1.txt", "file2.txt", "file3.txt", "file4.txt"));
}

TEST(facter_util_directory, each_file_pattern) {
    vector<string> files;

    directory::each_file(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls", [&](string const& file) {
        files.push_back(boost::filesystem::path(file).filename().string());
        return true;
    }, "^file[23].txt$");

    sort(files.begin(), files.end());

    ASSERT_THAT(files, ElementsAre("file2.txt", "file3.txt"));
}

TEST(facter_util_directory, each_subdirectory) {
    vector<string> subdirectories;

    directory::each_subdirectory(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external", [&](string const& directory) {
        subdirectories.push_back(boost::filesystem::path(directory).filename().string());
        return true;
    });

    sort(subdirectories.begin(), subdirectories.end());

    ASSERT_THAT(subdirectories, ElementsAre("json", "posix", "text", "windows", "yaml"));
}

TEST(facter_util_directory, each_subdirectory_pattern) {
    vector<string> subdirectories;

    directory::each_subdirectory(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external", [&](string const& directory) {
        subdirectories.push_back(boost::filesystem::path(directory).filename().string());
        return true;
    }, "^[jy].*$");

    sort(subdirectories.begin(), subdirectories.end());

    ASSERT_THAT(subdirectories, ElementsAre("json", "yaml"));
}
