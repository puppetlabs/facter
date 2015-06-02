#include <internal/facts/resolvers/load_average_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    load_average_resolver::load_average_resolver() :
        resolver(
            "load_average",
            {
                fact::load_averages,
            }
        )
    {
    }

    void load_average_resolver::resolve(collection& facts)
    {
        /* Get the load averages */
        auto averages = get_load_averages();
        if (!averages) {
            return;
        }

        auto value = make_value<map_value>();
        value->add("1m",  make_value<double_value>(get<0>(*averages)));
        value->add("5m",  make_value<double_value>(get<1>(*averages)));
        value->add("15m", make_value<double_value>(get<2>(*averages)));
        facts.add(fact::load_averages, move(value));
    }

}}}  // namespace facter::facts::resolvers
