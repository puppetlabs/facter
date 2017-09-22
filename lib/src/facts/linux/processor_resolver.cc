#include <internal/facts/linux/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <unordered_set>

using namespace std;
using namespace boost::filesystem;

namespace lth_file = leatherman::file_util;
namespace lth_util = leatherman::util;

namespace facter { namespace facts { namespace linux {
    static bool split_line(string const& line, string& key, string& value) {
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
            return (boost::starts_with(data.isa, "ppc64")) ? POWER : GENERIC;
        }

        // use /proc/cpuinfo
        unordered_set<string> to_be_seen;
        bool seen_all = false;
        lth_file::each_line(root + "/proc/cpuinfo", [&](string& line) {
            // if we already know that we're on a Power machine, we can just skip
            // the remaining lines
            if (seen_all) {
                return true;
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

        return seen_all ? POWER : GENERIC;
    }

    void processor_resolver::add_generic_cpu_data(data& data, bool have_counts, std::string const& root)
    {
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
    }

    void processor_resolver::add_power_cpu_data(data& data, bool have_counts, std::string const& root)
    {
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
            } else if (!id.empty() && key == "cpu") {
                // Add the model for this logical processor
                data.models.emplace_back(move(value));
            } else if (key == "clock" && data.speed == 0) {
                // Parse out the processor speed (in MHz)
                string speed;
                if (lth_util::re_search(value, boost::regex("(\\d+).*MHz"), &speed)) {
                    data.speed = stoi(speed);
                }
            }
            return true;
        });

    }

    void processor_resolver::add_cpu_data(data& data, std::string const& root)
    {
        unordered_set<string> cpus;
        lth_file::each_subdirectory(root + "/sys/devices/system/cpu", [&](string const& cpu_directory) {
            ++data.logical_count;
            string id = lth_file::read((path(cpu_directory) / "/topology/physical_package_id").string());
            boost::trim(id);
            if (id.empty() || cpus.emplace(move(id)).second) {
                // Haven't seen this processor before
                ++data.physical_count;
            }
            return true;
        }, "^cpu\\d+$");

        bool have_counts = data.logical_count > 0;
        
        if (architecture_type(data, root) == GENERIC) {
            add_generic_cpu_data(data, have_counts, root);
        } else {
            add_power_cpu_data(data, have_counts, root); 
        }
       
        if (data.speed != 0) {
            return;
        }

        // Read in the max speed from the first cpu
        // The speed is in kHz
        string speed = lth_file::read(root + "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq");
        if (!speed.empty()) {
            try {
                data.speed = stoi(speed) * static_cast<int64_t>(1000);
            } catch (invalid_argument&) {
            }
        }
    }

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);
        add_cpu_data(result);
        return result;
    }

}}}  // namespace facter::facts::linux
