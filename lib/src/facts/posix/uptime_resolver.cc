#include <boost/format.hpp>
#include <facter/execution/execution.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/integer_value.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/facts/posix/uptime_resolver.hpp>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include <re2/re2.h>

using namespace std;
using boost::format;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace posix {

    void uptime_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all uptime-related facts
        resolve_uptime_seconds(facts);  // must be first b/c the following facts are based on this
        resolve_uptime_hours(facts);
        resolve_uptime_days(facts);
        resolve_uptime(facts);
    }

    void uptime_resolver::resolve_uptime_seconds(fact_map& facts)
    {
        int value = executable_uptime();
        facts.add(fact::uptime_seconds, make_value<integer_value>(value));
    }

    void uptime_resolver::resolve_uptime_hours(fact_map& facts)
    {
        auto uptime_seconds = facts.get<integer_value>(fact::uptime_seconds);
        if (!uptime_seconds) {
            return;
        }
        int uptime_hours = uptime_seconds->value() / (60 * 60);
        string value = to_string(uptime_hours);
        facts.add(fact::uptime_hours, make_value<integer_value>(value));
    }

    void uptime_resolver::resolve_uptime_days(fact_map& facts)
    {
        auto uptime_seconds = facts.get<integer_value>(fact::uptime_seconds);
        if (!uptime_seconds) {
            return;
        }
        int uptime_days = uptime_seconds->value() / (60 * 60 * 24);
        string value = to_string(uptime_days);
        facts.add(fact::uptime_days, make_value<integer_value>(value));
    }

    void uptime_resolver::resolve_uptime(fact_map& facts)
    {
        auto uptime_seconds = facts.get<integer_value>(fact::uptime_seconds);
        if (!uptime_seconds) {
            return;
        }
        int seconds = uptime_seconds->value();

        int days    = seconds / (60 * 60 * 24);
        int hours   = (seconds / (60 * 60)) % 24;
        int minutes = (seconds / 60) % 60;

        string value;
        switch (days) {
            case 0:
                value = (format("%d:%02d hours") % hours % minutes).str();
                break;
            case 1:
                value = "1 day";
                break;
            default:
                value = (format("%d days") % days).str();
        }
        facts.add(fact::uptime, make_value<string_value>(std::move(value)));
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
