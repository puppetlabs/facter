#include <internal/facts/freebsd/zpool_resolver.hpp>

using namespace std;

namespace facter { namespace facts { namespace freebsd {

    string zpool_resolver::zpool_command()
    {
        return "/sbin/zpool";
    }

}}}  // namespace facter::facts::freebsd
