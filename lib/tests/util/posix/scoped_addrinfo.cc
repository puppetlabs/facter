#include <gmock/gmock.h>
#include <facter/util/posix/scoped_addrinfo.hpp>

using namespace std;
using namespace facter::util::posix;

TEST(facter_util_posix_scoped_addrinfo, construction) {
    scoped_addrinfo info("localhost");
    ASSERT_EQ(0, info.result());
    ASSERT_NE(nullptr, static_cast<addrinfo*>(info));
}
