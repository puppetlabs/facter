#include <internal/facts/resolvers/uptime_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <boost/format.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    uptime_resolver::uptime_resolver() :
        resolver(
            "uptime",
            {
                fact::system_uptime,
                fact::uptime,
                fact::uptime_days,
                fact::uptime_hours,
                fact::uptime_seconds
            })
    {
    }

    void uptime_resolver::resolve(collection& facts)
    {
        auto seconds = get_uptime();
        if (seconds < 0) {
            return;
        }

        auto minutes = (seconds / 60) % 60;
        auto hours = seconds / (60 * 60);
        auto days = seconds / (60 * 60 * 24);
        string uptime;

        switch (days) {
            case 0:
                uptime = (boost::format("%d:%02d hours") % hours % minutes).str();
                break;
            case 1:
                uptime = "1 day";
                break;
            default:
                uptime = (boost::format("%d days") % days).str();
                break;
        }

        // Add hidden facts
        facts.add(fact::uptime_seconds, make_value<integer_value>(seconds, true));
        facts.add(fact::uptime_hours, make_value<integer_value>(hours, true));
        facts.add(fact::uptime_days, make_value<integer_value>(days, true));
        facts.add(fact::uptime, make_value<string_value>(uptime, true));

        auto value = make_value<map_value>();
        value->add("seconds", make_value<integer_value>(seconds));
        value->add("hours", make_value<integer_value>(hours));
        value->add("days", make_value<integer_value>(days));
        value->add("uptime", make_value<string_value>(move(uptime)));
        facts.add(fact::system_uptime, move(value));
    }

}}}  // namespace facter::facts::resolvers
