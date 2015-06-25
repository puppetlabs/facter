#include <catch.hpp>
#include <internal/facts/resolvers/system_profiler_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_system_profiler_resolver : system_profiler_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_system_profiler_resolver : system_profiler_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.boot_mode = "boot_mode";
        result.boot_rom_version = "boot_rom_version";
        result.boot_volume = "boot_volume";
        result.processor_name = "processor_name";
        result.processor_speed = "processor_speed";
        result.kernel_version = "kernel_version";
        result.l2_cache_per_core = "l2_cache_per_core";
        result.l3_cache = "l3_cache";
        result.computer_name = "computer_name";
        result.model_identifier = "model_identifier";
        result.model_name = "model_name";
        result.cores = "cores";
        result.system_version = "system_version";
        result.processors = "processors";
        result.memory = "memory";
        result.hardware_uuid = "hardware_uuid";
        result.secure_virtual_memory = "secure_virtual_memory";
        result.serial_number = "serial_number";
        result.smc_version = "smc_version";
        result.uptime = "uptime";
        result.username = "username";
        return result;
    }
};

SCENARIO("using the system profiler resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_system_profiler_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        static const vector<string> algorithms = {
            "dsa",
            "ecdsa",
            "ed25519",
            "rsa"
        };
        facts.add(make_shared<test_system_profiler_resolver>());
        THEN("a structured fact is added") {
            auto system_profiler = facts.get<map_value>(fact::system_profiler);
            REQUIRE(system_profiler);
            REQUIRE(system_profiler->size() == 21u);
            static const vector<string> names = {
                "boot_mode",
                "boot_rom_version",
                "boot_volume",
                "processor_name",
                "processor_speed",
                "kernel_version",
                "l2_cache_per_core" ,
                "l3_cache",
                "computer_name",
                "model_identifier",
                "model_name",
                "cores",
                "system_version",
                "processors",
                "memory",
                "hardware_uuid",
                "secure_virtual_memory",
                "serial_number",
                "smc_version",
                "uptime",
                "username"
            };
            for (auto const& name : names) {
                auto sval = system_profiler->get<string_value>(name);
                REQUIRE(sval);
                REQUIRE(sval->value() == name);
            }
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 22u);
            static const map<string, string> check = {
                { string(fact::sp_boot_mode), "boot_mode" },
                { string(fact::sp_boot_rom_version), "boot_rom_version" },
                { string(fact::sp_boot_volume), "boot_volume" },
                { string(fact::sp_cpu_type), "processor_name" },
                { string(fact::sp_current_processor_speed), "processor_speed" },
                { string(fact::sp_kernel_version), "kernel_version" },
                { string(fact::sp_l2_cache_core), "l2_cache_per_core" },
                { string(fact::sp_l3_cache), "l3_cache" },
                { string(fact::sp_local_host_name), "computer_name" },
                { string(fact::sp_machine_model), "model_identifier" },
                { string(fact::sp_machine_name), "model_name" },
                { string(fact::sp_number_processors), "cores" },
                { string(fact::sp_os_version), "system_version" },
                { string(fact::sp_packages), "processors" },
                { string(fact::sp_physical_memory), "memory" },
                { string(fact::sp_platform_uuid), "hardware_uuid" },
                { string(fact::sp_secure_vm), "secure_virtual_memory" },
                { string(fact::sp_serial_number), "serial_number" },
                { string(fact::sp_smc_version_system), "smc_version" },
                { string(fact::sp_uptime), "uptime" },
                { string(fact::sp_user_name), "username" }
            };
            for (auto const& kvp : check) {
                auto sval = facts.get<string_value>(kvp.first);
                REQUIRE(sval);
                REQUIRE(sval->value() == kvp.second);
            }
        }
    }
}
