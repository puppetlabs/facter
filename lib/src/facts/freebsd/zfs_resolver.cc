#include <internal/facts/freebsd/zfs_resolver.hpp>

using namespace std;

namespace facter { namespace facts { namespace freebsd {

    string zfs_resolver::zfs_command()
    {
        return "/sbin/zfs";
    }

}}}  // namespace facter::facts::freebsd
