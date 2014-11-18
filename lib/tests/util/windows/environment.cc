#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <facter/util/windows/windows.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::util;

TEST(facter_util_environment, get) {
    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
    SetEnvironmentVariableW(L"FACTER_ENV_TEST", L"FOO");
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("FOO", value);
    SetEnvironmentVariableW(L"FACTER_ENV_TEST", nullptr);
    value = "";
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
}

TEST(facter_util_environment, set) {
    wchar_t buf[12];
    ASSERT_EQ(0, GetEnvironmentVariableW(L"FACTER_ENV_TEST", buf, 12));
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", "FOO"));
    GetEnvironmentVariableW(L"FACTER_ENV_TEST", buf, 12);
    ASSERT_EQ(wstring(L"FOO"), wstring(buf, 3));
    SetEnvironmentVariableW(L"FACTER_ENV_TEST", nullptr);
}

TEST(facter_util_environment, set_empty) {
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", ""));

    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
}

TEST(facter_util_environment, clear) {
    SetEnvironmentVariableW(L"FACTER_ENV_TEST", L"FOO");
    ASSERT_TRUE(environment::clear("FACTER_ENV_TEST"));

    wchar_t buf[12];
    ASSERT_EQ(0, GetEnvironmentVariableW(L"FACTER_ENV_TEST", buf, 12));
    ASSERT_EQ(ERROR_ENVVAR_NOT_FOUND, GetLastError());
}

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
    ASSERT_EQ(0u, count(paths.begin(), paths.end(), ""));

    ASSERT_TRUE(environment::set("PATH", value));
    environment::reload_search_paths();
}
