#include <gmock/gmock.h>
#include <facter/util/bsd/scoped_ifaddrs.hpp>

using namespace std;
using namespace facter::util::bsd;

TEST(facter_util_bsd_scoped_ifaddrs, construction) {
    scoped_ifaddrs addrs;
    ASSERT_NE(nullptr, static_cast<ifaddrs*>(addrs));
}
