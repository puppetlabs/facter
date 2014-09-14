#include <facter/facts/zfs/zpool_resolver.hpp>
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

LOG_DECLARE_NAMESPACE("facts.zfs.zpool");

namespace facter { namespace facts { namespace zfs {

    zpool_resolver::zpool_resolver() :
        resolver(
            "ZFS Zpool information",
            {
                string(fact::zpool_version),
                string(fact::zpool_featurenumbers),
                string(fact::zpools),
            })
    {
    }

    /*
     * For version strings, these are the available outputs in OpenZFS and solaris
        ; On OpenZFS
        This system supports ZFS pool feature flags.

        The following features are supported:

        FEAT DESCRIPTION
        -------------------------------------------------------------
        async_destroy                         (read-only compatible)
             Destroy filesystems asynchronously.
        empty_bpobj                           (read-only compatible)
             Snapshots use less space.
        lz4_compress                         
             LZ4 compression algorithm support.

        The following legacy versions are also supported:

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
         21  Deduplication
         22  Received properties
         23  Slim ZIL
         24  System attributes
         25  Improved scrub stats
         26  Improved snapshot deletion performance
         27  Improved snapshot creation performance
         28  Multiple vdev replacements

        For more information on a particular version, including supported releases,
        see the ZFS Administration Guide.

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

     void zpool_resolver::resolve_facts(collection& facts)
     {
       /*
        * Solaris ZFS still follows a simple linear versioning
        */
         string val;
         string version;
         vector<string> nver;
         re_adapter re_zpool_nversion("\\s*(\\d+)[ ]");
         execution::each_line(zpool_cmd(), {"upgrade", "-v"}, [&] (string& line) {
               if (re_search(line, re_zpool_nversion, &val)) {
                   nver.push_back(move(val));
               }
               return true;
         });
         facts.add(fact::zpool_featurenumbers, make_value<string_value>(boost::join(nver, ",")));
         auto pools = make_value<array_value>();
         for (auto const& zp : zpool_list()) {
             auto value = make_value<map_value>();
             auto pool = make_value<map_value>();
             value->add("size", make_value<string_value>(zp.size));
             value->add("available", make_value<string_value>(zp.available));
             value->add("disks", make_value<string_value>(boost::join(zp.disks, ",")));
             pool->add(string(zp.name), move(value));
             pools->add(move(pool));
         }
         facts.add(fact::zpools, move(pools));
     }

     vector<zpool> zpool_resolver::zpool_list()
     {
         string val;
         vector<zpool> zvec;
         execution::each_line(zpool_cmd(), {"list", "-H"}, [&] (string& line) {
            vector<string> lst;
            boost::split(lst, line, boost::is_any_of(" \t"), boost::token_compress_on);
            if (lst.size() < 1) {
                // Either the zpool list has failed, or the format of output has changed
                // in either case we should not continue.
                LOG_DEBUG("zpool_resolver 'zpool list -H' failed");
                return false;
            }
            vector<string> disks;
            bool parse = false;
            execution::each_line(zpool_cmd(), {"status", lst[0]}, [&] (string& sline) {
               // begin parsing from config:, and end at errors:
               if (boost::starts_with(sline, "config:")) {
                  parse = true;
                  return true;
               }
               if (boost::starts_with(sline, "errors:")) {
                  parse = false;
                  return false;
               }
               if (boost::starts_with(sline, "NAME")) {
                  return true;
               }
               if (boost::starts_with(sline, lst[0])) {
                  return true;
               }

               if (parse) {
                  vector<string> slst;
                  boost::split(slst, sline, boost::is_any_of(" \t"), boost::token_compress_on);
                  if (slst.size() > 0) {
                      disks.push_back(move(slst[0]));
                  } else {
                     LOG_DEBUG("zpool_resolver 'zpool status' failed: invalid line");
                  }
               }
               return true;
            });
            zvec.push_back(zpool{move(lst[0]), move(lst[1]), move(lst[3]), move(disks)});
            return true;
         });
         return zvec;
     }

}}}  // namespace facter::facts::zfs
