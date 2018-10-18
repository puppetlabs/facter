#include <internal/facts/windows/dmi_resolver.hpp>
#include <leatherman/windows/wmi.hpp>
#include <leatherman/logging/logging.hpp>

using namespace std;
using namespace leatherman::windows;

namespace facter { namespace facts { namespace windows {

    dmi_resolver::dmi_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::dmi_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        auto vals = _wmi->query(wmi::computersystemproduct, {wmi::name, wmi::uuid});
        if (vals.empty()) {
            LOG_DEBUG("WMI query returned no results for {1} with values {2} and {3}.", wmi::computersystemproduct, wmi::name, wmi::uuid);
        } else {
            result.product_name = wmi::get(vals, wmi::name);
            result.uuid = wmi::get(vals, wmi::uuid);
        }

        vals = _wmi->query(wmi::bios, {wmi::manufacturer, wmi::serialnumber});
        if (vals.empty()) {
            LOG_DEBUG("WMI query returned no results for {1} with values {2} and {3}.", wmi::bios, wmi::serialnumber, wmi::manufacturer);
        } else {
            result.serial_number = wmi::get(vals, wmi::serialnumber);
            result.manufacturer = wmi::get(vals, wmi::manufacturer);
        }

        return result;
    }

}}}  // namespace facter::facts::windows
