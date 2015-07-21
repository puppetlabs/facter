#include <internal/facts/solaris/zone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::util;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace solaris {

    zone_resolver::data zone_resolver::collect_data(collection& facts)
    {
        data result;
        result.current_zone_name = get<1>(execute("/bin/zonename"));

        static boost::regex zone_pattern("(\\d+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)");

        each_line("/usr/sbin/zoneadm", {"list", "-p"}, [&](string& line) {
            zone z;
            if (re_search(line, zone_pattern, &z.id, &z.name, &z.status, &z.path, &z.uuid, &z.brand, &z.ip_type)) {
                result.zones.emplace_back(move(z));
            }
            return true;
        });
        return result;
    }
}}}  // namespace facter::facts::solaris
