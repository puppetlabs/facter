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
        if (!vals.empty()) {
            result.product_name = vals[wmi::name];
        }

        vals = wmi::query(wmi::bios, {wmi::manufacturer, wmi::serialnumber});
        if (!vals.empty()) {
            result.serial_number = vals[wmi::serialnumber];
            result.manufacturer = vals[wmi::manufacturer];
        }

        return result;
    }

}}}  // namespace facter::facts::windows
