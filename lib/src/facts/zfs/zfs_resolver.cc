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

LOG_DECLARE_NAMESPACE("facts.zfs.zfs");

namespace facter { namespace facts { namespace zfs {

    zfs_resolver::zfs_resolver() :
        resolver(
            "ZFS information",
            {
                string(fact::zfs_version),
                string(fact::zfs_featurenumbers),
                string(fact::zfs_datasets)
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

     void zfs_resolver::resolve_facts(collection& facts)
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

         auto sets = make_value<array_value>();
         for (auto const& zp : zfs_list()) {
             auto value = make_value<map_value>();
             auto zset = make_value<map_value>();
             value->add("size", make_value<string_value>(zp.size));
             for (auto & prop : zp.props) {
                value->add(string(prop.first), make_value<string_value>(prop.second));
             }
             zset->add(string(zp.name), move(value));
             sets->add(move(zset));
         }
         facts.add(fact::zfs_datasets, move(sets));
     }

     vector<zfs> zfs_resolver::zfs_list()
     {
         string val;
         vector<zfs> zvec;
         execution::each_line(zfs_cmd(), {"list", "-H"}, [&] (string& line) {
            vector<string> lst;
            boost::split(lst, line, boost::is_any_of(" \t"), boost::token_compress_on);
            if (lst.size() < 2) {
                // The list -H all seems to have failed for some reason, or
                // the format of the get -H all output has changed. In
                // either case, we dont want to continue processing

                LOG_DEBUG("zfs_resolver 'zfs list -H' failed");
                return false;
            }
            // name, used, avail, refer, mount
            map<string, string> props;
            execution::each_line(zfs_cmd(), {"get", "-H", "all", lst[0]}, [&] (string& zline) {
                vector<string> plst;
                boost::split(plst, zline, boost::is_any_of(" \t"), boost::token_compress_on);
                if (plst.size() < 2) {
                    // The get -H all seems to have failed for some reason, or
                    // the format of the get -H all output has changed. In
                    // either case, we dont want to continue processing
                    LOG_DEBUG("zfs_resolver 'zfs get -H all' failed");
                    return false;
                }
                props.insert({move(plst[1]), move(plst[2])});
                return true;
            });
            zvec.push_back(zfs{move(lst[0]), move(lst[1]), move(props)});
            return true;
         });
         return zvec;
     }

}}}  // namespace facter::facts::zfs
