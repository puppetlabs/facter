#include <facter/facts/windows/dmi_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string/join.hpp>
#include <map>

using namespace std;
using namespace facter::util;
using namespace facter::execution;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.dmi"

namespace facter { namespace facts { namespace windows {

    static map<string, string> query(string const& group, vector<string> const& keys)
    {
        map<string, string> vals;

        each_line("wmic",
            {"wmic", group, "GET", boost::join(keys, ","), "/format:textvaluelist.xsl"},
            [&](string &line) {
                auto eq = line.find('=');
                if (eq != string::npos) {
                    vals.emplace(line.substr(0, eq), line.substr(eq+1));
                }
                return true;
            }, {execution_options::defaults, execution_options::redirect_stderr});

        return vals;
    }

    namespace wmi {
        constexpr static char const* name = "Name";
        constexpr static char const* manufacturer = "Manufacturer";
        constexpr static char const* serialnumber = "SerialNumber";
    }

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        auto vals = query("csproduct", {wmi::name});
        if (vals.empty()) {
            LOG_ERROR("wmic failed");
            return result;
        }
        result.product_name = move(vals[wmi::name]);

        vals = query("bios", {wmi::manufacturer, wmi::serialnumber});
        if (vals.empty()) {
            LOG_ERROR("wmic failed");
            return result;
        }
        result.serial_number = move(vals[wmi::serialnumber]);
        result.manufacturer = move(vals[wmi::manufacturer]);

        return result;
    }

}}}  // namespace facter::facts::windows
