#include <facter/facts/osx/system_profiler_resolver.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <map>
#include <functional>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;

namespace facter { namespace facts { namespace osx {

    system_profiler_resolver::data system_profiler_resolver::collect_data(collection& facts)
    {
        static map<string, function<string&(data&)>> data_map = {
            { "Boot Mode",              [](data& d) -> string& { return d.boot_mode; } },
            { "Boot ROM Version",       [](data& d) -> string& { return d.boot_rom_version; } },
            { "Boot Volume",            [](data& d) -> string& { return d.boot_volume; } },
            { "Processor Name",         [](data& d) -> string& { return d.processor_name; } },
            { "Processor Speed",        [](data& d) -> string& { return d.processor_speed; } },
            { "Kernel Version",         [](data& d) -> string& { return d.kernel_version; } },
            { "L2 Cache (per Core)",    [](data& d) -> string& { return d.l2_cache_per_core; } },
            { "L3 Cache",               [](data& d) -> string& { return d.l3_cache; } },
            { "Computer Name",          [](data& d) -> string& { return d.computer_name; } },
            { "Model Identifier",       [](data& d) -> string& { return d.model_identifier; } },
            { "Model Name",             [](data& d) -> string& { return d.model_name; } },
            { "Total Number of Cores",  [](data& d) -> string& { return d.cores; } },
            { "System Version",         [](data& d) -> string& { return d.system_version; } },
            { "Number of Processors",   [](data& d) -> string& { return d.processors; } },
            { "Memory",                 [](data& d) -> string& { return d.memory; } },
            { "Hardware UUID",          [](data& d) -> string& { return d.hardware_uuid; } },
            { "Secure Virtual Memory",  [](data& d) -> string& { return d.secure_virtual_memory; } },
            { "Serial Number (system)", [](data& d) -> string& { return d.serial_number; } },
            { "SMC Version (system)",   [](data& d) -> string& { return d.smc_version; } },
            { "Time since boot",        [](data& d) -> string& { return d.uptime; } },
            { "User Name",              [](data& d) -> string& { return d.username; } }
        };

        data result;
        size_t count = 0;
        execution::each_line("/usr/sbin/system_profiler", { "SPSoftwareDataType", "SPHardwareDataType" }, [&](string& line) {
            // Split at the first ':'
            auto pos = line.find(':');
            if (pos == string::npos) {
                return true;
            }
            string key = line.substr(0, pos);
            boost::trim(key);
            string value = line.substr(pos + 1);
            boost::trim(value);

            // Lookup the data based on the "key"
            auto it = data_map.find(key);
            if (it == data_map.end()) {
                return true;
            }
            it->second(result) = move(value);

            // Continue only if we haven't collected all the data
            return ++count < data_map.size();
        });

        return result;
    }

}}}  // namespace facter::facts::osx
