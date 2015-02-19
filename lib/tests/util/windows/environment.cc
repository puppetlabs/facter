#include <catch.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/windows/windows.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::util;

SCENARIO("path separator on Windows") {
    REQUIRE(environment::get_path_separator() == ';');
}

SCENARIO("environment search paths") {
    GIVEN("paths from the environment") {
        auto paths = environment::search_paths();
        REQUIRE(paths.size() > 0);
    }
    GIVEN("empty paths from the environment") {
        string value;
        REQUIRE(environment::get("PATH", value));
        REQUIRE(environment::set("PATH", value+";"));
        environment::reload_search_paths();
        auto paths = environment::search_paths();
        THEN("an empty path should not be searched") {
            REQUIRE(count(paths.begin(), paths.end(), "") == 0);
        }
        REQUIRE(environment::set("PATH", value));
        environment::reload_search_paths();
    }
}
