#include <boost/format.hpp>
#include <facter/execution/execution.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/posix/uptime_resolver.hpp>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include <re2/re2.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace posix {

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

    void uptime_resolver::resolve_facts(collection& facts)
    {
        // Resolve all uptime-related facts
        resolve_system_uptime(facts);  // Must be first b/c the following facts are based on this
        resolve_uptime_seconds(facts);
        resolve_uptime_hours(facts);
        resolve_uptime_days(facts);
        resolve_uptime(facts);
    }

    void uptime_resolver::resolve_system_uptime(collection& facts)
    {
        int seconds = executable_uptime();
        if (!seconds) {
          return;
        }

        int minutes = (seconds / 60) % 60;
        int hours   = seconds / (60 * 60);
        int days    = seconds / (60 * 60 * 24);
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
        }
        auto system_uptime_value = make_value<map_value>();
        system_uptime_value->add("seconds", make_value<integer_value>(seconds));
        system_uptime_value->add("hours", make_value<integer_value>(hours));
        system_uptime_value->add("days", make_value<integer_value>(days));
        system_uptime_value->add("uptime", make_value<string_value>(uptime));
        facts.add(fact::system_uptime, move(system_uptime_value));
    }

    void uptime_resolver::resolve_uptime_seconds(collection& facts)
    {
        auto system_uptime   = facts.get<map_value>(fact::system_uptime, false);
        if (!system_uptime) {
            return;
        }
        facts.add(fact::uptime_seconds, make_value<integer_value>(system_uptime->get<integer_value>("seconds")->value()));
    }

    void uptime_resolver::resolve_uptime_hours(collection& facts)
    {
        auto system_uptime = facts.get<map_value>(fact::system_uptime, false);
        if (!system_uptime) {
            return;
        }
        facts.add(fact::uptime_hours, make_value<integer_value>(system_uptime->get<integer_value>("hours")->value()));
    }

    void uptime_resolver::resolve_uptime_days(collection& facts)
    {
        auto system_uptime = facts.get<map_value>(fact::system_uptime, false);
        if (!system_uptime) {
            return;
        }
        facts.add(fact::uptime_days, make_value<integer_value>(system_uptime->get<integer_value>("days")->value()));
    }

    void uptime_resolver::resolve_uptime(collection& facts)
    {
        auto system_uptime = facts.get<map_value>(fact::system_uptime, false);
        if (!system_uptime) {
            return;
        }
        facts.add(fact::uptime, make_value<string_value>(move(system_uptime->get<string_value>("uptime")->value())));
    }

    // call the uptime executable
    int uptime_resolver::executable_uptime()
    {
        string uptime_output = execute("uptime");
        if (uptime_output.empty()) {
            return 0;
        }
        return parse_executable_uptime(uptime_output);
    }

    // parse the output from the uptime executable
    int uptime_resolver::parse_executable_uptime(string const& output)
    {
        // This regex parsing is directly ported from facter:
        // https://github.com/puppetlabs/facter/blob/2.0.1/lib/facter/util/uptime.rb#L42-L60

        int days, hours, minutes;

        if (RE2::PartialMatch(output, "(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+):(\\d+)", &days, &hours, &minutes)) {
            return 86400 * days + 3600 * hours + 60 * minutes;
        } else if (RE2::PartialMatch(output, "(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+) hr(?:s|\\(s\\))?,", &days, &hours)) {
            return 86400 * days + 3600 * hours;
        } else if (RE2::PartialMatch(output, "(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+) min(?:s|\\(s\\))?,", &days, &minutes)) {
            return 86400 * days + 60 * minutes;
        } else if (RE2::PartialMatch(output, "(\\d+) day(?:s|\\(s\\))?,", &days)) {
            return 86400 * days;
        } else if (RE2::PartialMatch(output, "up\\s+(\\d+):(\\d+),", &hours, &minutes)) {
            return 3600 * hours + 60 * minutes;
        } else if (RE2::PartialMatch(output, "(\\d+) hr(?:s|\\(s\\))?,", &hours)) {
            return 3600 * hours;
        } else if (RE2::PartialMatch(output, "(\\d+) min(?:s|\\(s\\))?,", &minutes)) {
            return 60 * minutes;
        } else {
           return 0;
        }
    }

}}}  // namespace facter::facts::posix
