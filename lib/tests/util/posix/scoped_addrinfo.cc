#include <catch.hpp>
#include <internal/util/posix/scoped_addrinfo.hpp>

using namespace std;
using namespace facter::util::posix;

SCENARIO("constructing a scoped_addrinfo") {
    scoped_addrinfo info("localhost");
    REQUIRE(info.result() == 0);
    REQUIRE(static_cast<addrinfo*>(info));
}
