#include <internal/facts/windows/disk_resolver.hpp>
#include <leatherman/windows/wmi.hpp>
#include <leatherman/logging/logging.hpp>
#include <stdlib.h>

using namespace std;
using namespace leatherman::windows;

namespace facter { namespace facts { namespace windows {

    disk_resolver::disk_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::disk_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    disk_resolver::data disk_resolver::collect_data(collection& facts)
    {
        data result;
        string size;
        string diskid;
        auto vals = _wmi->query(wmi::diskdrive, {wmi::index, wmi::serialnumber, wmi::model, wmi::size, wmi::interfacetype});
        if (vals.empty()) {
            LOG_DEBUG("WMI query returned no results for {1} with values {2}, {3}, {4}, {5} and {6}.", wmi::diskdrive, wmi::index, wmi::serialnumber, wmi::model, wmi::size, wmi::interfacetype);
        } else {
            float tmp;
            string tmpS;
            tmpS = wmi::get(vals, wmi::size);
            tmp = strof(tmpS, NULL)/(1024*1024*1024);
            diskid = std::to_string(wmi::get(vals, wmi::index));
            size = std::to_string(tmp) + " GiB";
            result.diskid.model = wmi::get(vals, wmi::model);
            result.diskid.serial_number = wmi::get(vals, wmi::serialnumber);
            result.diskid.size = wmi::get(vals, size);
            result.diskid.size_bytes = tmpS;
            result.diskid.vendor = wmi::get(vals, wmi::interfacetype);
        }

        return result;
    }

}}}  // namespace facter::facts::windows
