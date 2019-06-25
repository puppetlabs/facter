#include <internal/facts/posix/uptime_resolver.hpp>
#ifdef HAVE_UTMPX_H
#include <internal/util/posix/utmpx_file.hpp>
#endif
#include <leatherman/util/regex.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>

#include <ctime>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;
using namespace leatherman::util;
using namespace leatherman::execution;
#ifdef HAVE_UTMPX_H
using namespace facter::util::posix;
#endif

namespace facter { namespace facts { namespace posix {

    int64_t uptime_resolver::parse_uptime(string const& output)
    {
        // This regex parsing is directly ported from facter:
        // https://github.com/puppetlabs/facter/blob/2.0.1/lib/facter/util/uptime.rb#L42-L60

        static boost::regex days_hours_mins_pattern("(\\d+) day(?:s|\\(s\\))?,?\\s+(\\d+):-?(\\d+)");
        static boost::regex days_hours_pattern("(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+) hr(?:s|\\(s\\))?,");
        static boost::regex days_mins_pattern("(\\d+) day(?:s|\\(s\\))?,\\s+(\\d+) min(?:s|\\(s\\))?,");
        static boost::regex days_pattern("(\\d+) day(?:s|\\(s\\))?,");
        static boost::regex hours_mins_pattern("up\\s+(\\d+):-?(\\d+),");
        static boost::regex hours_pattern("(\\d+) hr(?:s|\\(s\\))?,");
        static boost::regex mins_pattern("(\\d+) min(?:s|\\(s\\))?,");

        int days, hours, minutes;

        if (re_search(output, days_hours_mins_pattern, &days, &hours, &minutes)) {
            return 86400ll * days + 3600ll * hours + 60ll * minutes;
        } else if (re_search(output, days_hours_pattern, &days, &hours)) {
            return 86400ll * days + 3600ll * hours;
        } else if (re_search(output, days_mins_pattern, &days, &minutes)) {
            return 86400ll * days + 60ll * minutes;
        } else if (re_search(output, days_pattern, &days)) {
            return 86400ll * days;
        } else if (re_search(output, hours_mins_pattern, &hours, &minutes)) {
            return 3600ll * hours + 60ll * minutes;
        } else if (re_search(output, hours_pattern, &hours)) {
            return 3600ll * hours;
        } else if (re_search(output, mins_pattern, &minutes)) {
            return 60ll * minutes;
        }
        return -1;
    }

    int64_t uptime_resolver::get_uptime()
    {
#ifdef HAVE_UTMPX_H
        LOG_DEBUG(_("Attempting to calculate the uptime from the utmpx file"));
        utmpx query;
        query.ut_type = BOOT_TIME;
        utmpx_file file;
        auto ent = file.query(query);
        if (ent) {
          return time(NULL) - ent->ut_tv.tv_sec;
        }
        LOG_DEBUG(_("Could not calculate the uptime from the utmpx file"));
#endif

        auto exec = execute("uptime");
        if (!exec.success) {
            return -1;
        }
        return parse_uptime(exec.output);
    }

}}}  // namespace facter::facts::posix
