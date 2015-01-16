#include <facter/facts/windows/uptime_resolver.hpp>
#include <facter/util/windows/wmi.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/regex.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/gregorian/gregorian_types.hpp>

namespace facter { namespace facts { namespace windows {

    using namespace std;
    using namespace facter::util;
    using namespace facter::util::windows;
    using namespace boost::posix_time;
    using namespace boost::gregorian;

    uptime_resolver::uptime_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::uptime_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    static ptime get_ptime(string const& wmitime)
    {
        re_adapter wmi_regex("^(\\d{8,})(\\d{2})(\\d{2})(\\d{2})\\.");
        string iso_date;
        int hour, min, sec;
        if (!re_search(wmitime, wmi_regex, &iso_date, &hour, &min, &sec)) {
          throw runtime_error((boost::format("failed to parse %1% as a date/time") % wmitime).str());
        }

        return ptime(from_undelimited_string(iso_date), time_duration(hour, min, sec));
    }

    int64_t uptime_resolver::get_uptime()
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
