#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <unistd.h>
#include <windows.h>

using namespace std;
using namespace facter::util;

TEST(facter_util_environment, get) {
    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
    SetEnvironmentVariable("FACTER_ENV_TEST", "FOO");
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("FOO", value);
    SetEnvironmentVariable("FACTER_ENV_TEST", nullptr);
    value = "";
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
}

TEST(facter_util_environment, set) {
    char buf[12];
    ASSERT_EQ(0, GetEnvironmentVariable("FACTER_ENV_TEST", buf, 12));
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", "FOO"));
    GetEnvironmentVariable("FACTER_ENV_TEST", buf, 12);
    ASSERT_EQ(string("FOO"), string(buf, 3));
    SetEnvironmentVariable("FACTER_ENV_TEST", nullptr);
}

TEST(facter_util_environment, set_empty) {
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", ""));

    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
}

TEST(facter_util_environment, clear) {
    SetEnvironmentVariable("FACTER_ENV_TEST", "FOO");
    ASSERT_TRUE(environment::clear("FACTER_ENV_TEST"));

    char buf[12];
    ASSERT_EQ(0, GetEnvironmentVariable("FACTER_ENV_TEST", buf, 12));
    ASSERT_EQ(ERROR_ENVVAR_NOT_FOUND, GetLastError());
}

TEST(facter_util_environment, get_path_separator) {
    ASSERT_EQ(';', environment::get_path_separator());
}

TEST(facter_util_environment, search_paths) {
    auto paths = environment::search_paths();
    ASSERT_GT(paths.size(), 1u);
}
