#include <facter/facts/posix/uptime_resolver.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/regex.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace posix {

    int64_t uptime_resolver::parse_uptime(string const& output)
    {
        // This regex parsing is directly ported from facter:
        // https://github.com/puppetlabs/facter/blob/2.0.1/lib/facter/util/uptime.rb#L42-L60

        int days, hours, minutes;

        if (re_search(output, "(\\d+) day(?:s|\\(s\\))?,?\\s+(\\d+):-?(\\d+)", &days, &hours, &minutes)) {
            return 86400ll * days + 3600ll * hours + 60ll * minutes;
        } else if (re_search(output, "(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+) hr(?:s|\\(s\\))?,", &days, &hours)) {
            return 86400ll * days + 3600ll * hours;
        } else if (re_search(output, "(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+) min(?:s|\\(s\\))?,", &days, &minutes)) {
            return 86400ll * days + 60ll * minutes;
        } else if (re_search(output, "(\\d+) day(?:s|\\(s\\))?,", &days)) {
            return 86400ll * days;
        } else if (re_search(output, "up\\s+(\\d+):-?(\\d+),", &hours, &minutes)) {
            return 3600ll * hours + 60ll * minutes;
        } else if (re_search(output, "(\\d+) hr(?:s|\\(s\\))?,", &hours)) {
            return 3600ll * hours;
        } else if (re_search(output, "(\\d+) min(?:s|\\(s\\))?,", &minutes)) {
            return 60ll * minutes;
        }
        return -1;
    }

    int64_t uptime_resolver::get_uptime()
    {
        auto result = execute("uptime");
        if (!result.first || result.second.empty()) {
            return -1;
        }
        return parse_uptime(result.second);
    }

}}}  // namespace facter::facts::posix
