#include <catch.hpp>
#include <internal/facts/windows/operating_system_resolver.hpp>
#include <leatherman/util/environment.hpp>
#include <leatherman/windows/windows.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace leatherman::util;

SCENARIO("Read SYSTEMROOT OS environment variable") {
    GIVEN("Windows 32 and 64 bit OS") {
        string value;
        REQUIRE(environment::get("SystemRoot", value));
        string required = "C:\\WINDOWS";
        boost::algorithm::to_upper(value);
        REQUIRE(required == value);
    }
}
