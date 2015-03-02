#include <facter/facts/solaris/zpool_resolver.hpp>

using namespace std;

namespace facter { namespace facts { namespace solaris {

    string zpool_resolver::zpool_command()
    {
        return "/sbin/zpool";
    }

}}}  // namespace facter::facts::solaris
