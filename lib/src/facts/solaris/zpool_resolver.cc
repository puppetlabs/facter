#include <facter/facts/solaris/zpool_resolver.hpp>
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

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.solaris.zpool"

namespace facter { namespace facts { namespace solaris {

    string zpool_resolver::zpool_cmd()
    {
        // the openzfs location is /sbin/zpool in both Solaris and Ubuntu but
        // /usr/sbin/zpool in OSX
        return "/sbin/zpool";
    }

    /*
        ; On solaris
        | zpool upgrade -v
        This system is currently running ZFS pool version 32.

        The following versions are supported:

        VER  DESCRIPTION
        ---  --------------------------------------------------------
         1   Initial ZFS version
         2   Ditto blocks (replicated metadata)
         3   Hot spares and double parity RAID-Z
         4   zpool history
         5   Compression using the gzip algorithm
         6   bootfs pool property
         7   Separate intent log devices
         8   Delegated administration
         9   refquota and refreservation properties
         10  Cache devices
         11  Improved scrub performance
         12  Snapshot properties
         13  snapused property
         14  passthrough-x aclinherit
         15  user/group space accounting
         16  stmf property support
         17  Triple-parity RAID-Z
         18  Snapshot user holds
         19  Log device removal
         20  Compression using zle (zero-length encoding)
         21  Reserved
         22  Received properties
         23  Slim ZIL
         24  System attributes
         25  Improved scrub stats
         26  Improved snapshot deletion performance
         27  Improved snapshot creation performance
         28  Multiple vdev replacements
         29  RAID-Z/mirror hybrid allocator
         30  Reserved
         31  Improved 'zfs list' performance
         32  One MB blocksize

        For more information on a particular version, including supported releases,
        see the ZFS Administration Guide.

     */


    void zpool_resolver::resolve(collection& facts)
    {
        // Solaris ZFS still follows a simple linear versioning
        string val;
        string version;
        vector<string> nver;
        re_adapter re_zpool_version("ZFS pool version (\\d+)[.]");
        execution::each_line(zpool_cmd(), {"upgrade", "-v"}, [&] (string& line) {
              if (re_search(line, re_zpool_version, &version)) {
                  return true;
              }
              return true;
        });
        facts.add(fact::zpool_featurenumbers, make_value<string_value>(boost::join(nver, ",")));
        facts.add(fact::zpool_version, make_value<string_value>(move(version)));

        zfs::zpool_resolver::resolve(facts);
    }
}}}  // namespace facter::facts::solaris
