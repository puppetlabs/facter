#include <facter/facts/solaris/zfs_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/regex.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <facter/logging/logging.hpp>
#include <vector>
#include <string>
#include <map>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace solaris {

    string zfs_resolver::zfs_cmd()
    {
        // the openzfs location is /sbin/zpool in both Solaris and Ubuntu but
        // /usr/sbin/zpool in OSX
        return "/sbin/zfs";
    }
}}}  // namespace facter::facts::solaris
