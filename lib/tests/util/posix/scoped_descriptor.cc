#include <catch.hpp>
#include <internal/util/posix/scoped_descriptor.hpp>
#include <sys/socket.h>
#include <fcntl.h>

using namespace std;
using namespace facter::util::posix;

SCENARIO("constructing a POSIX scoped descriptor") {

    int sock = socket(AF_INET, SOCK_DGRAM, 0);

    {
        scoped_descriptor scoped(sock);
    }

    // This check could theoretically fail if the OS reassigns the file
    // descriptor between the above destructor call and this line
    // This likely will not happen during testing.
    REQUIRE(fcntl(sock, F_GETFD) == -1);
    REQUIRE(errno == EBADF);
}
