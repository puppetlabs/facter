#include <internal/facts/linux/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/file.hpp>
#include <facter/util/directory.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <unordered_set>

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;

namespace facter { namespace facts { namespace linux {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);

        unordered_set<string> cpus;
        directory::each_subdirectory("/sys/devices/system/cpu", [&](string const& cpu_directory) {
            ++result.logical_count;
            string id = file::read((path(cpu_directory) / "/topology/physical_package_id").string());
            boost::trim(id);
            if (id.empty() || cpus.emplace(move(id)).second) {
                // Haven't seen this processor before
                ++result.physical_count;
            }
            return true;
        }, "^cpu\\d+$");

        // To determine model information, parse /proc/cpuinfo
        bool have_counts = result.logical_count > 0;
        string id;
        file::each_line("/proc/cpuinfo", [&](string& line) {
            // Split the line on colon
            auto pos = line.find(":");
            if (pos == string::npos) {
                return true;
            }
            string key = line.substr(0, pos);
            boost::trim(key);
            string value = line.substr(pos + 1);
            boost::trim(value);

            if (key == "processor") {
                // Start of a logical processor
                id = move(value);
                if (!have_counts) {
                    ++result.logical_count;
                }
            } else if (!id.empty() && key == "model name") {
                // Add the model for this logical processor
                result.models.emplace_back(move(value));
            } else if (!have_counts && key == "physical id" && cpus.emplace(move(value)).second) {
                // Couldn't determine physical count from sysfs, but CPU topology is present, so use it
                ++result.physical_count;
            }
            return true;
        });

        // Read in the max speed from the first cpu
        // The speed is in kHz
        string speed = file::read("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq");
        if (!speed.empty()) {
            try {
                result.speed = stoi(speed) * static_cast<int64_t>(1000);
            } catch (invalid_argument&) {
            }
        }

        return result;
    }

}}}  // namespace facter::facts::linux
