#include <internal/facts/solaris/zone_resolver.hpp>
#include <internal/util/regex.hpp>
#include <facter/facts/collection.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace solaris {

    zone_resolver::data zone_resolver::collect_data(collection& facts)
    {
        data result;
        result.current_zone_name = execution::execute("/bin/zonename").second;

        static boost::regex zone_pattern("(\\d+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)");

        execution::each_line("/usr/sbin/zoneadm", {"list", "-p"}, [&](string& line) {
            zone z;
            if (re_search(line, zone_pattern, &z.id, &z.name, &z.status, &z.path, &z.uuid, &z.brand, &z.ip_type)) {
                result.zones.emplace_back(move(z));
            }
            return true;
        });
        return result;
    }
}}}  // namespace facter::facts::solaris
