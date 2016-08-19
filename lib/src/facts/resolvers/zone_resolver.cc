#include <internal/facts/resolvers/zone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace resolvers {

    zone_resolver::zone_resolver() :
        resolver(
            "Solaris zone",
            {
                fact::zones,
                fact::zonename,
                fact::solaris_zones,
            },
            {
                string("^zone_.+_") + fact::zone_id + "$",
                string("^zone_.+_") + fact::zone_name + "$",
                string("^zone_.+_") + fact::zone_status + "$",
                string("^zone_.+_") + fact::zone_path + "$",
                string("^zone_.+_") + fact::zone_uuid + "$",
                string("^zone_.+_") + fact::zone_brand + "$",
                string("^zone_.+_") + fact::zone_iptype + "$"
            }
        )
    {
    }

    void zone_resolver::resolve(collection& facts, set<string> const& blocklist)
    {
        auto data = collect_data(facts);

        auto zones = make_value<map_value>();
        for (auto& zone : data.zones) {
            auto value = make_value<map_value>();

            if (!zone.id.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_id, make_value<string_value>(zone.id, true));
                value->add("id", make_value<string_value>(move(zone.id)));
            }
            if (!zone.name.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_name, make_value<string_value>(zone.name, true));
            }
            if (!zone.status.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_status, make_value<string_value>(zone.status, true));
                value->add("status", make_value<string_value>(move(zone.status)));
            }
            if (!zone.path.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_path, make_value<string_value>(zone.path, true));
                value->add("path", make_value<string_value>(move(zone.path)));
            }
            if (!zone.uuid.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_uuid, make_value<string_value>(zone.uuid, true));
                value->add("uuid", make_value<string_value>(move(zone.uuid)));
            }
            if (!zone.brand.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_brand, make_value<string_value>(zone.brand, true));
                value->add("brand", make_value<string_value>(move(zone.brand)));
            }
            if (!zone.ip_type.empty()) {
                facts.add(string("zone_") + zone.name + "_" + fact::zone_iptype, make_value<string_value>(zone.ip_type, true));
                value->add("ip_type", make_value<string_value>(move(zone.ip_type)));
            }

            zones->add(move(zone.name), move(value));
        }

        facts.add(fact::zones, make_value<integer_value>(zones->size(), true));

        if (zones->size() > 0) {
            auto solaris_zones = make_value<map_value>();

            if (!data.current_zone_name.empty()) {
                solaris_zones->add("current", make_value<string_value>(data.current_zone_name));
            }

            solaris_zones->add("zones", move(zones));
            facts.add(fact::solaris_zones, move(solaris_zones));
        }

        if (!data.current_zone_name.empty()) {
            facts.add(fact::zonename, make_value<string_value>(move(data.current_zone_name), true));
        }
    }

}}}  // namespace facter::facts::resolvers
