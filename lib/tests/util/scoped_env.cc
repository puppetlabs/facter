#include <catch.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/scoped_env.hpp>

using namespace std;
using namespace facter::util;

SCENARIO("scoping an environment variable") {
    string value;
    REQUIRE_FALSE(environment::get("FACTER_ENV_TEST", value));
    REQUIRE(value.empty());

    WHEN("the variable does not exist") {
        AND_WHEN("the variable is scoped") {
            scoped_env foo("FACTER_ENV_TEST", "FOO");
            THEN("the new value is set") {
                REQUIRE(environment::get("FACTER_ENV_TEST", value));
                REQUIRE(value == "FOO");
            }
        }
    }
    WHEN("the variable exists")
    {
        environment::set("FACTER_ENV_TEST", "bar");

        AND_WHEN("the variable is scoped") {
            scoped_env foo("FACTER_ENV_TEST", "FOO");
            THEN("the new value is set") {
                REQUIRE(environment::get("FACTER_ENV_TEST", value));
                REQUIRE(value == "FOO");
            }
        }
        THEN("the variable should be restored") {
            REQUIRE(environment::get("FACTER_ENV_TEST", value));
            REQUIRE(value == "bar");
        }

        environment::clear("FACTER_ENV_TEST");
    }
}
