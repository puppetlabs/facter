#include <gmock/gmock.h>
#include <facter/util/posix/scoped_descriptor.hpp>
#include <sys/socket.h>
#include <fcntl.h>

using namespace std;
using namespace facter::util::posix;

TEST(facter_util_posix_scoped_descriptor, construction) {
    int sock = socket(AF_INET, SOCK_DGRAM, 0);

    {
        scoped_descriptor scoped(sock);
    }

    // This check could theoretically fail if the OS reassigns the file
    // descriptor between the above destructor call and this line
    // This likely will not happen during testing.
    ASSERT_EQ(-1, fcntl(sock, F_GETFD));
    ASSERT_EQ(EBADF, errno);
}
