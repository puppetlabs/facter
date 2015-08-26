#include <internal/facts/windows/uptime_resolver.hpp>
#include <leatherman/windows/wmi.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/gregorian/gregorian_types.hpp>

namespace facter { namespace facts { namespace windows {

    using namespace std;
    using namespace leatherman::util;
    using namespace leatherman::windows;
    using namespace boost::posix_time;
    using namespace boost::gregorian;

    uptime_resolver::uptime_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::uptime_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    static ptime get_ptime(string const& wmitime)
    {
        static boost::regex wmi_regex("^(\\d{8,})(\\d{2})(\\d{2})(\\d{2})\\.");
        string iso_date;
        int hour, min, sec;
        if (!re_search(wmitime, wmi_regex, &iso_date, &hour, &min, &sec)) {
          throw runtime_error((boost::format("failed to parse %1% as a date/time") % wmitime).str());
        }

        return ptime(from_undelimited_string(iso_date), time_duration(hour, min, sec));
    }

    int64_t uptime_resolver::get_uptime(collection& facts)
    {
        auto vals = _wmi->query(wmi::operatingsystem, {wmi::lastbootuptime, wmi::localdatetime});
        if (vals.empty()) {
            return -1;
        }

        ptime boottime = get_ptime(wmi::get(vals, wmi::lastbootuptime));
        ptime now = get_ptime(wmi::get(vals, wmi::localdatetime));
        return (now - boottime).total_seconds();
    }

}}}  // namespace facter::facts::windows
