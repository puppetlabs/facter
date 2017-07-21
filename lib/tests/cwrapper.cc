#include <catch.hpp>
#include <facter/cwrapper.hpp>

SCENARIO("using the C wrapper function to collect default facts") {
    GIVEN("a get_default_facts invocation") {
        char *result {nullptr};

        THEN("no error should be thrown") {
            REQUIRE_NOTHROW(get_default_facts(&result));
        }

        THEN("the function execution should succeed") {
            REQUIRE(get_default_facts(&result) == 0);
        }

        THEN("the function stores the collected facts and sets the pointer arg") {
            REQUIRE(result == nullptr);
            get_default_facts(&result);
            REQUIRE_FALSE(result == nullptr);
        }
    }
}
