#include <facter/facts/solaris/zone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <boost/algorithm/string.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>

#include <string>
#include <vector>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.solaris.zone"

namespace facter { namespace facts { namespace solaris {

    zone_resolver::zone_resolver() :
        resolver(
            "zone",
            {
                fact::zones,
                fact::zonename,
            },
            {
                string("^zone_.+") + fact::zone_id,
                string("^zone_.+") + fact::zone_name,
                string("^zone_.+") + fact::zone_state,
                string("^zone_.+") + fact::zone_path,
                string("^zone_.+") + fact::zone_uuid,
                string("^zone_.+") + fact::zone_brand,
                string("^zone_.+") + fact::zone_iptype
            }
            )
    {
    }

    void zone_resolver::resolve(collection& facts)
    {
        auto res = execution::execute("/bin/zonename");
        if (!res.first) {
            LOG_DEBUG("zone resolver failed");
            return;
        }
        string zonename = res.second;
        string zoneid, name, zonestate, zonepath, zoneuuid, zonebrand, iptype;
        vector<tuple<string, string, string, string, string, string, string>> zones;
        re_adapter zre("(\\d+):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)");
        execution::each_line("/usr/sbin/zoneadm", {"list", "-p"}, [&] (string& line) {
            if (re_search(line, zre,  &zoneid, &name, &zonestate, &zonepath, &zoneuuid, &zonebrand, &iptype)) {
                zones.push_back(make_tuple(zoneid, name, zonestate, zonepath, zoneuuid, zonebrand, iptype));
            }
            return true;
        });

        for (auto& zone : zones) {
            string property = "zone_" + get<1>(zone) + "_";
            facts.add(property + fact::zone_id, make_value<string_value>(move(get<0>(zone))));
            facts.add(property + fact::zone_name, make_value<string_value>(move(get<1>(zone))));
            facts.add(property + fact::zone_state, make_value<string_value>(move(get<2>(zone))));
            facts.add(property + fact::zone_path, make_value<string_value>(move(get<3>(zone))));
            facts.add(property + fact::zone_uuid, make_value<string_value>(move(get<4>(zone))));
            facts.add(property + fact::zone_brand, make_value<string_value>(move(get<5>(zone))));
            facts.add(property + fact::zone_iptype, make_value<string_value>(move(get<6>(zone))));
        }

        facts.add(fact::zones, make_value<integer_value>(zones.size()));
        facts.add(fact::zonename, make_value<string_value>(move(zonename)));
    }
}}}  // namespace facter::facts::posix
