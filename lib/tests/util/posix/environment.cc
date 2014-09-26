#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::util;

TEST(facter_util_environment, get) {
    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
    setenv("FACTER_ENV_TEST", "FOO", 1);
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("FOO", value);
    unsetenv("FACTER_ENV_TEST");
    value = "";
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
}

TEST(facter_util_environment, set) {
    ASSERT_EQ(nullptr, getenv("FACTER_ENV_TEST"));
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", "FOO"));
    ASSERT_EQ(string("FOO"), getenv("FACTER_ENV_TEST"));
    unsetenv("FACTER_ENV_TEST");
}

TEST(facter_util_environment, set_empty) {
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", ""));

    string value;
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);

    unsetenv("FACTER_ENV_TEST");
}

TEST(facter_util_environment, clear) {
    setenv("FACTER_ENV_TEST", "FOO", 1);
    ASSERT_TRUE(environment::clear("FACTER_ENV_TEST"));
    ASSERT_EQ(nullptr, getenv("FACTER_ENV_TEST"));
}

TEST(facter_util_environment, get_path_separator) {
    ASSERT_EQ(':', environment::get_path_separator());
}

TEST(facter_util_environment, search_paths) {
    auto paths = environment::search_paths();
    ASSERT_GT(paths.size(), 2u);
    ASSERT_EQ("/sbin", *(paths.rbegin() + 1));
    ASSERT_EQ("/usr/sbin", *paths.rbegin());
}
