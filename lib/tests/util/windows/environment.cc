#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <facter/util/windows/windows.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::util;

TEST(facter_util_environment, get_path_separator) {
    ASSERT_EQ(';', environment::get_path_separator());
}

TEST(facter_util_environment, search_paths) {
    auto paths = environment::search_paths();
    ASSERT_GT(paths.size(), 0u);
}

TEST(facter_util_environment, search_paths_empty_path) {
    // Empty paths should not be included, as filesystem::path resolves them to cwd.
    string value;
    ASSERT_TRUE(environment::get("PATH", value));
    ASSERT_TRUE(environment::set("PATH", value+";"));
    environment::reload_search_paths();

    auto paths = environment::search_paths();
    ASSERT_EQ(0u, static_cast<unsigned int>(count(paths.begin(), paths.end(), "")));

    ASSERT_TRUE(environment::set("PATH", value));
    environment::reload_search_paths();
}
