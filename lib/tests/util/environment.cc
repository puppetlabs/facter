#include <gmock/gmock.h>
#include <facter/util/environment.hpp>
#include <boost/nowide/cenv.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::util;

TEST(facter_util_environment, get) {
    string value;
    ASSERT_FALSE(environment::get("FACTERTEST", value));
    ASSERT_EQ("", value);
    boost::nowide::setenv("FACTERTEST", "FOO", 1);
    ASSERT_TRUE(environment::get("FACTERTEST", value));
    ASSERT_EQ("FOO", value);
    boost::nowide::unsetenv("FACTERTEST");
    value = "";
    ASSERT_FALSE(environment::get("FACTERTEST", value));
    ASSERT_EQ("", value);
}

TEST(facter_util_environment, set) {
    ASSERT_EQ(nullptr, boost::nowide::getenv("FACTERTEST"));
    ASSERT_TRUE(environment::set("FACTERTEST", "FOO"));
    ASSERT_EQ(string("FOO"), boost::nowide::getenv("FACTERTEST"));
    boost::nowide::unsetenv("FACTERTEST");
}

TEST(facter_util_environment, set_empty) {
    ASSERT_TRUE(environment::set("FACTERTEST", ""));

    string value;
    ASSERT_TRUE(environment::get("FACTERTEST", value));
    ASSERT_EQ("", value);

    boost::nowide::unsetenv("FACTERTEST");
}

TEST(facter_util_environment, clear) {
    boost::nowide::setenv("FACTERTEST", "FOO", 1);
    ASSERT_TRUE(environment::clear("FACTERTEST"));
    ASSERT_EQ(nullptr, boost::nowide::getenv("FACTERTEST"));
}


TEST(facter_util_environment, each) {
    boost::nowide::setenv("FACTERTEST1", "FOO", 1);
    boost::nowide::setenv("FACTERTEST2", "BAR", 1);
    boost::nowide::setenv("FACTERTEST3", "BAZ", 1);

    string value1;
    string value2;
    string value3;
    environment::each([&](string& name, string& value) {
        if (name == "FACTERTEST1") {
            value1 = move(value);
        } else if (name == "FACTERTEST2") {
            value2 = move(value);
        } else if (name == "FACTERTEST3") {
            value3 = move(value);
        }
        return true;
    });

    ASSERT_EQ("FOO", value1);
    ASSERT_EQ("BAR", value2);
    ASSERT_EQ("BAZ", value3);

    int count_at_stop = 0;
    int count = 0;
    environment::each([&](string& name, string& value) {
        if (name == "FACTERTEST1") {
            count_at_stop = count;
            return false;
        }
        ++count;
        return true;
    });
    ASSERT_NE(0, count);
    ASSERT_EQ(count_at_stop, count);
}
