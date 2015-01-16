#include <facter/facts/zfs/zfs_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
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

namespace facter { namespace facts { namespace zfs {

    zfs_resolver::zfs_resolver() :
        resolver(
            "ZFS information",
            {
                string(fact::zfs_version),
                string(fact::zfs_featurenumbers)
            })
    {
    }

    /*
     * For version strings, these are the available outputs in OpenZFS and solaris
        ; On OpenZFS
        | zfs upgrade -v
        The following filesystem versions are supported:

        VER  DESCRIPTION
        ---  --------------------------------------------------------
         1   Initial ZFS filesystem version
         2   Enhanced directory entries
         3   Case insensitive and File system unique identifier (FUID)
         4   userquota, groupquota properties
         5   System attributes

        For more information on a particular version, including supported releases,
        see the ZFS Administration Guide.

        ; On solaris
        | zfs upgrade -v
        The following filesystem versions are supported:

        VER  DESCRIPTION
        ---  --------------------------------------------------------
         1   Initial ZFS filesystem version
         2   Enhanced directory entries
         3   Case insensitive and File system unique identifier (FUID)
         4   userquota, groupquota properties
         5   System attributes

        For more information on a particular version, including supported releases,
        see the ZFS Administration Guide.

     */

     void zfs_resolver::resolve(collection& facts)
     {
       /*
        * Solaris ZFS still follows a simple linear versioning
        */
         string val;
         string version;
         vector<string> nver;
         re_adapter re_zfs_nversion("\\s*(\\d+)[ ]");
         re_adapter re_zfs_version("currently running ZFS filesystem version (\\d+)[.]");
         execution::each_line(zfs_cmd(), {"upgrade", "-v"}, [&] (string& line) {
               if (re_search(line, re_zfs_nversion, &val)) {
                   nver.push_back(move(val));
               }
               return true;
         });
         execution::each_line(zfs_cmd(), {"upgrade"}, [&] (string& line) {
               if (re_search(line, re_zfs_version, &version)) {
                  return false;
               }
               return true;
         });
         if (!version.empty()) {
           facts.add(move(string(fact::zfs_version)), make_value<string_value>(version));
         }
         facts.add(move(string(fact::zfs_featurenumbers)), make_value<string_value>(boost::join(nver, ",")));
     }

}}}  // namespace facter::facts::zfs
