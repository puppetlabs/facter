#include <internal/facts/linux/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/file_util/directory.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <unordered_set>

using namespace std;
using namespace boost::filesystem;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

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

        // To determine model information, parse /proc/cpuinfo
        bool have_counts = data.logical_count > 0;
        string id;
        lth_file::each_line(root + "/proc/cpuinfo", [&](string& line) {
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
