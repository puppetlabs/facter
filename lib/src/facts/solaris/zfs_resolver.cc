#include <internal/facts/solaris/zfs_resolver.hpp>

using namespace std;

namespace facter { namespace facts { namespace solaris {

    string zfs_resolver::zfs_command()
    {
        return "/sbin/zfs";
    }

}}}  // namespace facter::facts::solaris
