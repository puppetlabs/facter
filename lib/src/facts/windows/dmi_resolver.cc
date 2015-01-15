#include <facter/facts/windows/dmi_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/wmi.hpp>

using namespace std;
using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    dmi_resolver::dmi_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::dmi_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        auto vals = _wmi->query(wmi::computersystemproduct, {wmi::name});
        result.product_name = wmi::get(vals, wmi::name);

        vals = _wmi->query(wmi::bios, {wmi::manufacturer, wmi::serialnumber});
        result.serial_number = wmi::get(vals, wmi::serialnumber);
        result.manufacturer = wmi::get(vals, wmi::manufacturer);

        return result;
    }

}}}  // namespace facter::facts::windows
