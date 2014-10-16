#include <facter/facts/osx/system_profiler_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <map>
#include <string>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;

namespace facter { namespace facts { namespace osx {

    system_profiler_resolver::system_profiler_resolver() :
        resolver(
            "system profiler",
            {
                fact::sp_boot_mode,
                fact::sp_boot_rom_version,
                fact::sp_boot_volume,
                fact::sp_cpu_type,
                fact::sp_current_processor_speed,
                fact::sp_kernel_version,
                fact::sp_l2_cache_core,
                fact::sp_l3_cache,
                fact::sp_local_host_name,
                fact::sp_machine_model,
                fact::sp_machine_name,
                fact::sp_number_processors,
                fact::sp_os_version,
                fact::sp_packages,
                fact::sp_physical_memory,
                fact::sp_platform_uuid,
                fact::sp_secure_vm,
                fact::sp_serial_number,
                fact::sp_smc_version_system,
                fact::sp_uptime,
                fact::sp_user_name,
            })
    {
    }

    void system_profiler_resolver::resolve(collection& facts)
    {
        static map<string, string> fact_names = {
            { "Boot Mode",              string(fact::sp_boot_mode) },
            { "Boot ROM Version",       string(fact::sp_boot_rom_version) },
            { "Boot Volume",            string(fact::sp_boot_volume) },
            { "Processor Name",         string(fact::sp_cpu_type) },
            { "Processor Speed",        string(fact::sp_current_processor_speed) },
            { "Kernel Version",         string(fact::sp_kernel_version) },
            { "L2 Cache (per Core)",    string(fact::sp_l2_cache_core) },
            { "L3 Cache",               string(fact::sp_l3_cache) },
            { "Computer Name",          string(fact::sp_local_host_name) },
            { "Model Identifier",       string(fact::sp_machine_model) },
            { "Model Name",             string(fact::sp_machine_name) },
            { "Total Number of Cores",  string(fact::sp_number_processors) },
            { "System Version",         string(fact::sp_os_version) },
            { "Number of Processors",   string(fact::sp_packages) },
            { "Memory",                 string(fact::sp_physical_memory) },
            { "Hardware UUID",          string(fact::sp_platform_uuid) },
            { "Secure Virtual Memory",  string(fact::sp_secure_vm) },
            { "Serial Number (system)", string(fact::sp_serial_number) },
            { "SMC Version (system)",   string(fact::sp_smc_version_system) },
            { "Time since boot",        string(fact::sp_uptime) },
            { "User Name",              string(fact::sp_user_name) },
        };

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

            // Lookup the fact name based on the "key"
            auto fact_name = fact_names.find(key);
            if (fact_name == fact_names.end()) {
                return true;
            }
            facts.add(string(fact_name->second), make_value<string_value>(move(value)));
            // Continue only if we haven't added all the facts
            return ++count < fact_names.size();
        });
    }

}}}  // namespace facter::facts::osx
