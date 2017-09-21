#include <catch.hpp>
#include <internal/facts/linux/filesystem_resolver.hpp>
#include <boost/filesystem.hpp>
#include "processor_fixture.hpp"

using namespace std;
using namespace facter::facts::linux;
using cpu_param = tuple<string, string, string, boost::optional<int64_t>>;
namespace fs = boost::filesystem;

SCENARIO("resolving processor-specific facts for linux machines") {
    string root_dir = fs::unique_path("temp_processor_resolver_root%%%%-%%%%-%%%%-%%%%").string();
    linux_processor_fixture fixture(root_dir);
    test_linux_processor_resolver resolver;

    GIVEN("/sys/devices/system/cpu contains cpu information and /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq exists") {
        fixture.reset();

        // here, speed is in KHz
        vector<cpu_param> cpu_params({
            make_tuple("Model A", "0", "0", 10),
            // ensure that duplicate CPUs are not counted twice in the
            // physical count
            make_tuple("Model B", "1", "0", 15),
            make_tuple("Model C", "2", "1", 20),
            make_tuple("Model D", "3", "2", 35), 
            // ensure that empty CPU ids are recognized as a valid physical cpu
	    make_tuple("Model E", "4", "", 35) 
        });
        setup_linux_processor_fixture(fixture, cpu_params);
        fixture.write_cpuinfo();
        auto result = resolver.collect_cpu_data(root_dir);

        REQUIRE(result.logical_count == 5);
        REQUIRE(result.physical_count == 4);
     
        array<string, 5> EXPECTED_MODELS{{"Model A", "Model B", "Model C", "Model D", "Model E"}};
        REQUIRE(result.models.size() == EXPECTED_MODELS.size());
        for (size_t i = 0; i < result.models.size(); ++i) {
            REQUIRE(result.models[i] == EXPECTED_MODELS[i]);
        }

        REQUIRE(result.speed == 10000);
    }

    GIVEN("/sys/devices/system/cpu contains cpu information and /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq does not exist") {
        fixture.reset();

        // here, speed is in KHz
        vector<cpu_param> cpu_params({
            make_tuple("Model A", "0", "0", boost::optional<int64_t>()),
            // ensure that duplicate CPUs are not counted twice in the
            // physical count
            make_tuple("Model B", "1", "0", 15),
            make_tuple("Model C", "2", "1", 20),
            make_tuple("Model D", "3", "2", 35), 
            // ensure that empty CPU ids are recognized as a valid physical cpu
	    make_tuple("Model E", "4", "", 35) 
        });
        setup_linux_processor_fixture(fixture, cpu_params);
        fixture.write_cpuinfo();
        auto result = resolver.collect_cpu_data(root_dir);

        REQUIRE(result.logical_count == 5);
        REQUIRE(result.physical_count == 4);
     
        array<string, 5> EXPECTED_MODELS{{"Model A", "Model B", "Model C", "Model D", "Model E"}};
        REQUIRE(result.models.size() == EXPECTED_MODELS.size());
        for (size_t i = 0; i < result.models.size(); ++i) {
            REQUIRE(result.models[i] == EXPECTED_MODELS[i]);
        }

        REQUIRE(result.speed == 0);
    }

    GIVEN("/sys/devices/system/cpu does not contain cpu information") {
        fixture.reset();

        // here, speed is in KHz
        vector<cpu_param> cpu_params({
            make_tuple("Model A", "0", "0", boost::optional<int64_t>()),
            // ensure that duplicate CPUs are not counted twice in the
            // physical count
            make_tuple("Model B", "1", "0", 15),
            make_tuple("Model C", "2", "1", 20),
            make_tuple("Model D", "3", "2", 35), 
            // ensure that a CPU with an empty logical ID's model name
            // is not collected
	    make_tuple("Model E", "", "3", 35) 
        });
        setup_linux_processor_fixture(fixture, cpu_params);
        fixture.write_cpuinfo();
        fixture.clear_sys_dir();

        // for this test, we want to ensure that the processor facts are obtained from
        // /proc/cpuinfo only.
        REQUIRE(fs::is_empty(fs::path(root_dir) / "sys" / "devices" / "system" / "cpu"));
        auto result = resolver.collect_cpu_data(root_dir);

        REQUIRE(result.logical_count == 5);
        REQUIRE(result.physical_count == 4);
     
        array<string, 4> EXPECTED_MODELS{{"Model A", "Model B", "Model C", "Model D"}};
        REQUIRE(result.models.size() == EXPECTED_MODELS.size());
        for (size_t i = 0; i < result.models.size(); ++i) {
            REQUIRE(result.models[i] == EXPECTED_MODELS[i]);
        }

        REQUIRE(result.speed == 0);
    }
}
