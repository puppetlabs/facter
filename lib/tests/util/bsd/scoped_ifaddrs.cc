#include <catch.hpp>
#include <facter/util/bsd/scoped_ifaddrs.hpp>

using namespace std;
using namespace facter::util::bsd;

SCENARIO("constructing a scoped_ifaddrs") {
    scoped_ifaddrs addrs;
    REQUIRE(static_cast<ifaddrs*>(addrs));
}
