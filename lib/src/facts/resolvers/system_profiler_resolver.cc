#include <facter/facts/resolvers/system_profiler_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace resolvers {

    system_profiler_resolver::system_profiler_resolver() :
        resolver(
            "system profiler",
            {
                fact::system_profiler,
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
        auto data = collect_data(facts);

        auto system_profiler = make_value<map_value>();
        if (!data.boot_mode.empty()) {
            facts.add(fact::sp_boot_mode, make_value<string_value>(data.boot_mode, true));
            system_profiler->add("boot_mode", make_value<string_value>(move(data.boot_mode)));
        }
        if (!data.boot_rom_version.empty()) {
            facts.add(fact::sp_boot_rom_version, make_value<string_value>(data.boot_rom_version, true));
            system_profiler->add("boot_rom_version", make_value<string_value>(move(data.boot_rom_version)));
        }
        if (!data.boot_volume.empty()) {
            facts.add(fact::sp_boot_volume, make_value<string_value>(data.boot_volume, true));
            system_profiler->add("boot_volume", make_value<string_value>(move(data.boot_volume)));
        }
        if (!data.processor_name.empty()) {
            facts.add(fact::sp_cpu_type, make_value<string_value>(data.processor_name, true));
            system_profiler->add("processor_name", make_value<string_value>(move(data.processor_name)));
        }
        if (!data.processor_speed.empty()) {
            facts.add(fact::sp_current_processor_speed, make_value<string_value>(data.processor_speed, true));
            system_profiler->add("processor_speed", make_value<string_value>(move(data.processor_speed)));
        }
        if (!data.kernel_version.empty()) {
            facts.add(fact::sp_kernel_version, make_value<string_value>(data.kernel_version, true));
            system_profiler->add("kernel_version", make_value<string_value>(move(data.kernel_version)));
        }
        if (!data.l2_cache_per_core.empty()) {
            facts.add(fact::sp_l2_cache_core, make_value<string_value>(data.l2_cache_per_core, true));
            system_profiler->add("l2_cache_per_core", make_value<string_value>(move(data.l2_cache_per_core)));
        }
        if (!data.l3_cache.empty()) {
            facts.add(fact::sp_l3_cache, make_value<string_value>(data.l3_cache, true));
            system_profiler->add("l3_cache", make_value<string_value>(move(data.l3_cache)));
        }
        if (!data.computer_name.empty()) {
            facts.add(fact::sp_local_host_name, make_value<string_value>(data.computer_name, true));
            system_profiler->add("computer_name", make_value<string_value>(move(data.computer_name)));
        }
        if (!data.model_identifier.empty()) {
            facts.add(fact::sp_machine_model, make_value<string_value>(data.model_identifier, true));
            system_profiler->add("model_identifier", make_value<string_value>(move(data.model_identifier)));
        }
        if (!data.model_name.empty()) {
            facts.add(fact::sp_machine_name, make_value<string_value>(data.model_name, true));
            system_profiler->add("model_name", make_value<string_value>(move(data.model_name)));
        }
        if (!data.cores.empty()) {
            facts.add(fact::sp_number_processors, make_value<string_value>(data.cores, true));
            system_profiler->add("cores", make_value<string_value>(move(data.cores)));
        }
        if (!data.system_version.empty()) {
            facts.add(fact::sp_os_version, make_value<string_value>(data.system_version, true));
            system_profiler->add("system_version", make_value<string_value>(move(data.system_version)));
        }
        if (!data.processors.empty()) {
            facts.add(fact::sp_packages, make_value<string_value>(data.processors, true));
            system_profiler->add("processors", make_value<string_value>(move(data.processors)));
        }
        if (!data.memory.empty()) {
            facts.add(fact::sp_physical_memory, make_value<string_value>(data.memory, true));
            system_profiler->add("memory", make_value<string_value>(move(data.memory)));
        }
        if (!data.hardware_uuid.empty()) {
            facts.add(fact::sp_platform_uuid, make_value<string_value>(data.hardware_uuid, true));
            system_profiler->add("hardware_uuid", make_value<string_value>(move(data.hardware_uuid)));
        }
        if (!data.secure_virtual_memory.empty()) {
            facts.add(fact::sp_secure_vm, make_value<string_value>(data.secure_virtual_memory, true));
            system_profiler->add("secure_virtual_memory", make_value<string_value>(move(data.secure_virtual_memory)));
        }
        if (!data.serial_number.empty()) {
            facts.add(fact::sp_serial_number, make_value<string_value>(data.serial_number, true));
            system_profiler->add("serial_number", make_value<string_value>(move(data.serial_number)));
        }
        if (!data.smc_version.empty()) {
            facts.add(fact::sp_smc_version_system, make_value<string_value>(data.smc_version, true));
            system_profiler->add("smc_version", make_value<string_value>(move(data.smc_version)));
        }
        if (!data.uptime.empty()) {
            facts.add(fact::sp_uptime, make_value<string_value>(data.uptime, true));
            system_profiler->add("uptime", make_value<string_value>(move(data.uptime)));
        }
        if (!data.username.empty()) {
            facts.add(fact::sp_user_name, make_value<string_value>(data.username, true));
            system_profiler->add("username", make_value<string_value>(move(data.username)));
        }

        if (!system_profiler->empty()) {
            facts.add(fact::system_profiler, move(system_profiler));
        }
    }

}}}  // namespace facter::facts::resolvers
