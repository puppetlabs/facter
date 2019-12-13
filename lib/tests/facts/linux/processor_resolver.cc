#include <catch.hpp>
#include <internal/facts/linux/filesystem_resolver.hpp>
#include <boost/filesystem.hpp>
#include <array>
#include "processor_fixture.hpp"

using namespace std;
using namespace facter::facts::linux;
using cpu_param = tuple<string, string, string, boost::optional<int64_t>>;
using architecture_type = test_linux_processor_resolver::ArchitectureType;
using test_data = test_linux_processor_resolver::test_linux_data;
namespace fs = boost::filesystem;

SCENARIO("determing the architecture of a linux machine") {
    test_linux_processor_resolver resolver;
    GIVEN("that the isa fact was successfully calculated") {
        WHEN("it starts with ppc64") {
            THEN("POWER is returned for the machine's architecture") {
                test_data data;
                array<string, 3> inputs{{"ppc64", "ppc64el", "ppc64le"}};
                for (auto& input : inputs) {
                    data.isa = input;
                    REQUIRE(resolver.architecture_type(data, "non-existent-root") == architecture_type::POWER);
                }
            }
        }
        WHEN("it does not start with ppc64") {
            THEN("X86 is returned for the machine's architecture") {
                test_data data;
                array<string, 3> inputs{{"x86_64", "i386", "amd64"}};
                for (auto& input : inputs) {
                    data.isa = input;
                    REQUIRE(resolver.architecture_type(data, "non-existent-root") == architecture_type::X86);
                }
            }
        }
    }
    GIVEN("that the isa fact was not successfully calculated") {
        string root_dir = fs::unique_path("temp_processor_resolver_root%%%%-%%%%-%%%%-%%%%").string();
        linux_processor_fixture fixture(root_dir, architecture_type::X86);
        WHEN("the /proc/cpuinfo file has the x86 structure") {
            THEN("X86 is returned for the machine's architecture") {
                fixture.reset();
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "0", 10),
                    make_tuple("Model B", "1", "1", 15),
                });
                setup_linux_processor_fixture(fixture, cpu_params);
                fixture.write_cpuinfo();

                test_data data;
                REQUIRE(resolver.architecture_type(data, "non-existent-root") == architecture_type::X86);
            }
        }
        WHEN("the proc/cpu/info file almost has the power structure") {
            THEN("X86 is returned for the machine's architecture") {
                fixture.reset(architecture_type::POWER);
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "0", 10),
                    make_tuple("Model B", "1", "1", 15),
                    make_tuple("Model C", "2", "2", 15),
                    make_tuple("Model D", "3", "3", 15)
                });

                vector<int> ids = setup_linux_processor_fixture(fixture, cpu_params);
                fixture.get_cpu(ids[0]).erase_info("processor");
                fixture.get_cpu(ids[1]).erase_info("cpu");
                fixture.get_cpu(ids[2]).erase_info("clock");
                fixture.get_cpu(ids[3]).erase_info("revision");
                fixture.write_cpuinfo();

                test_data data;
                REQUIRE(resolver.architecture_type(data, root_dir) == architecture_type::X86);
            }
        }
        WHEN("the proc/cpu/info file has the power structure") {
            THEN("POWER is returned for the machine's architecture") {
                fixture.reset(architecture_type::POWER);
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "0", 10),
                    make_tuple("Model B", "1", "1", 15),
                    make_tuple("Model C", "2", "2", 15),
                    make_tuple("Model D", "3", "3", 15)
                });
                vector<int> ids = setup_linux_processor_fixture(fixture, cpu_params);
                fixture.write_cpuinfo();

                test_data data;
                REQUIRE(resolver.architecture_type(data, root_dir) == architecture_type::POWER);
            }
        }
    }
}

SCENARIO("resolving processor-specific facts for linux machines") {
    string root_dir = fs::unique_path("temp_processor_resolver_root%%%%-%%%%-%%%%-%%%%").string();
    linux_processor_fixture fixture(root_dir, architecture_type::X86);
    test_linux_processor_resolver resolver;

    GIVEN("an x86 architecture") {
        WHEN("/sys/devices/system/cpu contains cpu information and /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq exists") {
            THEN("the processor facts are correctly resolved, and the speed is set to cpu0's speed") {
                fixture.reset();

                // here, speed is in KHz
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "0", 10),
                    // ensure that duplicate CPUs are not counted twice in the
                    // physical count
                    make_tuple("Model B", "1", "0", 15),
                    make_tuple("Model C", "2", "1", 20),
                    // ensure that some arbitrary string is also recognized as a valid physical cpu
                    make_tuple("Model D", "3", "some physical id", 35),
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
        }

        WHEN("/sys/devices/system/cpu contains cpu information and /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq does not exist") {
            THEN("the processor facts are correctly resolved, but the speed is not calculated") {
                fixture.reset();
                // here, speed is in KHz
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "0", boost::optional<int64_t>()),
                    // ensure that duplicate CPUs are not counted twice in the
                    // physical count
                    make_tuple("Model B", "1", "0", 15),
                    make_tuple("Model C", "2", "1", 20),
                    // ensure that some arbitrary string is also recognized as a valid physical cpu
                    make_tuple("Model D", "3", "some physical id", 35),
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
        }

        WHEN("/sys/devices/system/cpu does not contain cpu information") {
            THEN("the processor facts are correctly resolved, with the logical and physical counts are obtained from /proc/cpuinfo") {
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

        WHEN("/sys/devices/system/cpu contains cpu information but some cpus are offline") {
            THEN("the processor facts are correctly resolved for online cpus") {
                fixture.reset();

                // here, speed is in KHz
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "0", 10),
                    // ensure that duplicate CPUs are not counted twice in the
                    // physical count
                    make_tuple("Model B", "1", "0", 15),
                    make_tuple("Model C", "2", "1", 20),
                    make_tuple("Model D", "3", "2", 35),
                    make_tuple("Model E", "4", "3", 35)
                });
                vector<int> ids = setup_linux_processor_fixture(fixture, cpu_params);
                fixture.write_cpuinfo();

                // for this test, we want to ensure that Model D and Model E cpus are disabled, meaning the last 2 cpus will not have the topology folder
                int number_cpu_to_disable = 2;
                vector<cpu_param> disabled_cpu_params(cpu_params.end() - number_cpu_to_disable, cpu_params.end());

                for (auto& cpu_param : disabled_cpu_params) {
                    string logical_id = get<1>(cpu_param);
                    // Remove the topology foder for offline cpus
                    string topology_folder = root_dir + "/sys/devices/system/cpu"+ "/cpu"+logical_id + "/topology";
                    fs::remove_all(topology_folder);
                }

                auto result = resolver.collect_cpu_data(root_dir);

                // logical and physical count should count cpus without offline cpus
                REQUIRE(result.logical_count == 3);
                REQUIRE(result.physical_count == 2);
            }
        }
    }
    GIVEN("a power architecture") {
        WHEN("/sys/devices/system/cpu contains cpu information and /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq exists") {
            THEN("the processor facts are correctly resolved, with the speed being read from the 'clock' entry") {
                fixture.reset(architecture_type::POWER);

                // here, speed is in KHz
                vector<cpu_param> cpu_params({
                    // ensure that speed is read from the "clock" entry
                    make_tuple("Model A", "0", "0", boost::optional<int64_t>()),
                    // ensure that duplicate CPUs are not counted twice in the
                    // physical count
                    make_tuple("Model B", "1", "0", 15),
                    make_tuple("Model C", "2", "1", 20),
                    // ensure that some arbitrary string is also recognized as a valid physical cpu
                    make_tuple("Model D", "3", "some physical id", 35),
                    // ensure that empty CPU ids are recognized as a valid physical cpu
                    make_tuple("Model E", "4", "", 35),
                    // ensure that negative ids are not included in the physical count
                    // this entry simulates an invalid power cpu
                    make_tuple("Invalid CPU", "5", "-1", 35),
                });
                vector<int> ids = setup_linux_processor_fixture(fixture, cpu_params);
                fixture.get_cpu(ids.back()).erase_all_info();
                fixture.write_cpuinfo();
                auto result = resolver.collect_cpu_data(root_dir);

                REQUIRE(result.logical_count == 5);
                REQUIRE(result.physical_count == 4);

                array<string, 5> EXPECTED_MODELS{{"Model A", "Model B", "Model C", "Model D", "Model E"}};
                REQUIRE(result.models.size() == EXPECTED_MODELS.size());
                for (size_t i = 0; i < result.models.size(); ++i) {
                    REQUIRE(result.models[i] == EXPECTED_MODELS[i]);
                }

                REQUIRE(result.speed == 15000);
            }
        }

        WHEN("/sys/devices/system/cpu contains cpu information but cpu0 is invalid") {
            THEN("the processor facts are correctly resolved, but the speed is not calculated") {
                fixture.reset(architecture_type::POWER);

                // here, speed is in KHz
                vector<cpu_param> cpu_params({
                    make_tuple("Model A", "0", "-1", 15),
                    make_tuple("Model B", "0", "-1", -1)
                });
                vector<int> ids = setup_linux_processor_fixture(fixture, cpu_params);
                fixture.get_cpu(ids.front()).erase_all_info();
                fixture.write_cpuinfo();

                auto result = resolver.collect_cpu_data(root_dir);

                REQUIRE(result.logical_count == 1);
                // /proc/cpuinfo does not have any "physical_id" entries for power architectures
                REQUIRE(result.physical_count == 0);

                array<string, 1> EXPECTED_MODELS{{"Model B"}};
                REQUIRE(result.models.size() == EXPECTED_MODELS.size());
                for (size_t i = 0; i < result.models.size(); ++i) {
                  REQUIRE(result.models[i] == EXPECTED_MODELS[i]);
                }

                REQUIRE(result.speed == 0);
            }
        }

        WHEN("/sys/devices/system/cpu does not contain cpu information") {
            THEN("the processor facts are correctly resolved, with the speed being read from the 'clock' entry, but the physical count is not computed") {
                fixture.reset(architecture_type::POWER);

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
                // /proc/cpuinfo does not have any "physical_id" entries for power architectures
                REQUIRE(result.physical_count == 0);

                array<string, 4> EXPECTED_MODELS{{"Model A", "Model B", "Model C", "Model D"}};
                REQUIRE(result.models.size() == EXPECTED_MODELS.size());
                for (size_t i = 0; i < result.models.size(); ++i) {
                    REQUIRE(result.models[i] == EXPECTED_MODELS[i]);
                }

                REQUIRE(result.speed == 15000);
            }
        }
    }
}
