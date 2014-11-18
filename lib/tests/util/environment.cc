#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <boost/nowide/cenv.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::util;

TEST(facter_util_environment, get) {
    string value;
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
    boost::nowide::setenv("FACTER_ENV_TEST", "FOO", 1);
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("FOO", value);
    boost::nowide::unsetenv("FACTER_ENV_TEST");
    value = "";
    ASSERT_FALSE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);
}

TEST(facter_util_environment, set) {
    ASSERT_EQ(nullptr, boost::nowide::getenv("FACTER_ENV_TEST"));
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", "FOO"));
    ASSERT_EQ(string("FOO"), boost::nowide::getenv("FACTER_ENV_TEST"));
    boost::nowide::unsetenv("FACTER_ENV_TEST");
}

TEST(facter_util_environment, set_empty) {
    ASSERT_TRUE(environment::set("FACTER_ENV_TEST", ""));

    string value;
    ASSERT_TRUE(environment::get("FACTER_ENV_TEST", value));
    ASSERT_EQ("", value);

    boost::nowide::unsetenv("FACTER_ENV_TEST");
}

TEST(facter_util_environment, clear) {
    boost::nowide::setenv("FACTER_ENV_TEST", "FOO", 1);
    ASSERT_TRUE(environment::clear("FACTER_ENV_TEST"));
    ASSERT_EQ(nullptr, boost::nowide::getenv("FACTER_ENV_TEST"));
}
