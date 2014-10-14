#include <facter/facts/windows/dmi_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/wmi.hpp>

using namespace std;
using namespace facter::util::windows;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.dmi"

namespace facter { namespace facts { namespace windows {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        auto vals = wmi::query(wmi::computersystemproduct, {wmi::name});
        result.product_name = wmi::get(vals, wmi::name);

        vals = wmi::query(wmi::bios, {wmi::manufacturer, wmi::serialnumber});
        result.serial_number = wmi::get(vals, wmi::name);
        result.manufacturer = wmi::get(vals, wmi::manufacturer);

        return result;
    }

}}}  // namespace facter::facts::windows
