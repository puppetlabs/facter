#include <catch.hpp>
#include <facter/util/environment.hpp>
#include <boost/nowide/cenv.hpp>

using namespace std;
using namespace facter::util;

SCENARIO("getting an environment variable") {
    string value;
    REQUIRE_FALSE(environment::get("FACTERTEST", value));
    REQUIRE(value.empty());
    boost::nowide::setenv("FACTERTEST", "FOO", 1);
    REQUIRE(environment::get("FACTERTEST", value));
    REQUIRE(value == "FOO");
    boost::nowide::unsetenv("FACTERTEST");
    value = "";
    REQUIRE_FALSE(environment::get("FACTERTEST", value));
    REQUIRE(value.empty());
}

SCENARIO("setting an environment variable") {
    REQUIRE_FALSE(boost::nowide::getenv(""));
    GIVEN("a non-empty value") {
        REQUIRE(environment::set("FACTERTEST", "FOO"));
        THEN("the value is set to the same value") {
            REQUIRE(boost::nowide::getenv("FACTERTEST") == string("FOO"));
        }
        boost::nowide::unsetenv("FACTERTEST");
    }
    GIVEN("an empty value") {
        REQUIRE(environment::set("FACTERTEST", ""));
        THEN("the value is set to empty or not present") {
            string value;
            environment::get("FACTERTEST", value);
            REQUIRE(value == "");
        }
        boost::nowide::unsetenv("FACTERTEST");
    }
}

SCENARIO("clearing an environment variable") {
    boost::nowide::setenv("FACTERTEST", "FOO", 1);
    REQUIRE(environment::clear("FACTERTEST"));
    REQUIRE_FALSE(boost::nowide::getenv("FACTERTEST"));
}

SCENARIO("enumearing enviornment variables") {
    boost::nowide::setenv("FACTERTEST1", "FOO", 1);
    boost::nowide::setenv("FACTERTEST2", "BAR", 1);
    boost::nowide::setenv("FACTERTEST3", "BAZ", 1);
    WHEN("true is returned from the callback") {
        THEN("all values are returned") {
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
            REQUIRE(value1 == "FOO");
            REQUIRE(value2 == "BAR");
            REQUIRE(value3 == "BAZ");
        }
    }
    WHEN("false is returned from the callback") {
        THEN("enumeration stops") {
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
            REQUIRE(count != 0);
            REQUIRE(count == count_at_stop);
        }
    }
    boost::nowide::unsetenv("FACTERTEST1");
    boost::nowide::unsetenv("FACTERTEST2");
    boost::nowide::unsetenv("FACTERTEST3");
}
