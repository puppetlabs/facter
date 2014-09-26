#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <facter/util/scoped_env.hpp>

using namespace std;
using namespace facter::util;

TEST(facter_util_scoped_env, sets_environment) {
    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);

    {
        scoped_env foo("FACTER_ENV_TEST", "FOO");

        ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
        ASSERT_EQ("FOO", value);
    }

    value = "";
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
}

TEST(facter_util_scoped_env, changes_environment) {
    string value;
    environment::set("FACTER_ENV_TEST", "bar");
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("bar", value);

    {
        scoped_env foo("FACTER_ENV_TEST", "FOO");

        ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
        ASSERT_EQ("FOO", value);
    }

    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("bar", value);

    environment::clear("FACTER_ENV_TEST");
}
