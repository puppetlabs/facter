#include <internal/facts/linux/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <unordered_set>

using namespace std;
using namespace boost::filesystem;
using facter::util::maybe_stoi;

namespace lth_file = leatherman::file_util;
namespace lth_util = leatherman::util;

namespace facter { namespace facts { namespace linux {
    static bool split_line(string const& line, string& key, string& value)
    {
        // Split the line on colon
        auto pos = line.find(":");
        if (pos == string::npos) {
            return false;
        }
        key = line.substr(0, pos);
        boost::trim(key);
        value = line.substr(pos + 1);
        boost::trim(value);

        return true;
    }

    processor_resolver::ArchitectureType processor_resolver::architecture_type(data const& data, std::string const& root)
    {
        if (!data.isa.empty()) {
            return (boost::starts_with(data.isa, "ppc64")) ? ArchitectureType::POWER : ArchitectureType::X86;
        }

        // use /proc/cpuinfo
        unordered_set<string> to_be_seen;
        bool seen_all = false;
        lth_file::each_line(root + "/proc/cpuinfo", [&](string& line) {
            // if we already know that we're on a Power machine, we can just skip
            // the remaining lines
            if (seen_all) {
                return false;
            }

            string key, value;
            if (!split_line(line, key, value)) {
                return true;
            }

            if (key == "processor") {
                to_be_seen = unordered_set<string>{{"cpu", "clock", "revision"}};
            } else if (find(to_be_seen.begin(), to_be_seen.end(), key) != to_be_seen.end()) {
                to_be_seen.erase(key);
                seen_all = to_be_seen.empty();
            }
            return true;
        });

        return seen_all ? ArchitectureType::POWER : ArchitectureType::X86;
    }

    // returns true if the first cpu is a valid, physical cpu to use when computing the processor
    // speed
    bool processor_resolver::compute_cpu_counts(data& data, std::string const& root, std::function<bool(std::string const&)> is_valid_id) {
        unordered_set<string> cpus;
        bool cpu0_valid = false;

        lth_file::each_subdirectory(root + "/sys/devices/system/cpu", [&](string const& cpu_directory) {
            string physical_id_path = (path(cpu_directory) / "/topology/physical_package_id").string();
            if (lth_file::file_readable(physical_id_path)) {
                bool at_cpu0 = data.logical_count == 0;
                data.logical_count++;
                string id = lth_file::read(physical_id_path);
                boost::trim(id);
                if ((is_valid_id(id) && cpus.emplace(move(id)).second)) {
                    // Haven't seen this processor before
                    ++data.physical_count;
                    if (at_cpu0) {
                        cpu0_valid = true;
                    }
                }
            }

            return true;
        }, "^cpu\\d+$");

        return cpu0_valid;
    }

    void processor_resolver::maybe_add_speed(data& data, std::string const& speed, int magnitude)
    {
        auto maybe_speed = maybe_stoi(speed);
        if (maybe_speed && maybe_speed.get() > 0) {
            data.speed = maybe_speed.get() * static_cast<int64_t>(magnitude);
        }
    }

    bool processor_resolver::add_x86_cpu_data(data& data, std::string const& root)
    {
        bool cpu0_valid = compute_cpu_counts(data, root, [](string const& id) {
            // any id is fine for x86 cpus
            return true;
        });
        bool have_counts = data.logical_count > 0;

        unordered_set<string> cpus;
        string id;
        lth_file::each_line(root + "/proc/cpuinfo", [&](string& line) {
            string key, value;
            if (!split_line(line, key, value)) {
                return true;
            }

            if (key == "processor") {
                // Start of a logical processor
                id = move(value);
                if (!have_counts) {
                    ++data.logical_count;
                }
            } else if (!id.empty() && key == "model name") {
                // Add the model for this logical processor
                data.models.emplace_back(move(value));
            } else if (!have_counts && key == "physical id" && cpus.emplace(move(value)).second) {
                // Couldn't determine physical count from sysfs, but CPU topology is present, so use it
                ++data.physical_count;
            }
            return true;
        });

        return cpu0_valid;
    }

    bool processor_resolver::add_power_cpu_data(data& data, std::string const& root)
    {
        bool cpu0_valid = compute_cpu_counts(data, root, [](string const& id) {
            // only non-negative ids are allowed for power cpus
            auto maybe_id = maybe_stoi(id);
            return !maybe_id || maybe_id.get() >= 0;
        });

        // per ticket specs, logical count is computed below
        data.logical_count = 0;

        unordered_set<string> cpus;
        string id;
        lth_file::each_line(root + "/proc/cpuinfo", [&](string& line) {
            string key, value;
            if (!split_line(line, key, value)) {
                return true;
            }

            if (key == "processor") {
                // Start of a logical processor
                id = move(value);
                ++data.logical_count;
            } else if (!id.empty() && key == "cpu") {
                // Add the model for this logical processor
                data.models.emplace_back(move(value));
            } else if (key == "clock" && data.speed == 0) {
                // Parse out the processor speed (in MHz)
                string speed;
                if (lth_util::re_search(value, boost::regex("^(\\d+).*MHz"), &speed)) {
                    maybe_add_speed(data, speed, 1000000);
                }
            }
            return true;
        });

        return cpu0_valid;
    }

    void processor_resolver::add_cpu_data(data& data, std::string const& root)
    {
        bool cpu0_valid = (architecture_type(data, root) == ArchitectureType::X86) ?
            add_x86_cpu_data(data, root)
          : add_power_cpu_data(data, root);

        if (data.speed != 0 || !cpu0_valid) {
            return;
        }

        // Read in the max speed from the first cpu
        // The speed is in kHz
        string speed = lth_file::read(root + "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq");
        maybe_add_speed(data, speed, 1000);
    }

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);
        add_cpu_data(result);
        return result;
    }

}}}  // namespace facter::facts::linux
