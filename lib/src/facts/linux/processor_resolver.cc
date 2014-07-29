#include <facter/facts/linux/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/posix/os.hpp>
#include <facter/util/string.hpp>
#include <facter/util/file.hpp>
#include <facter/util/directory.hpp>
#include <boost/filesystem.hpp>
#include <re2/re2.h>
#include <unordered_set>

using namespace std;
using namespace re2;
using namespace facter::facts;
using namespace facter::facts::posix;
using namespace facter::util;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("facts.linux.processor");

namespace facter { namespace facts { namespace linux {

    void processor_resolver::resolve_architecture(collection& facts)
    {
        // Get the hardware model
        auto model = facts.get<string_value>(fact::hardware_model, false);
        if (!model) {
            posix::processor_resolver::resolve_architecture(facts);
            return;
        }

        // Get the operating system
        auto os = facts.get<string_value>(fact::operating_system);
        if (!os) {
            posix::processor_resolver::resolve_architecture(facts);
            return;
        }

        // For certain distros, use "amd64" for x86_64
        string value = model->value();
        if (model->value() == "x86_64") {
            if (os->value() == os::debian ||
                os->value() == os::gentoo ||
                os->value() == os::kfreebsd ||
                os->value() == os::ubuntu) {
                value = "amd64";
            }
        // For 32-bit, use "x86" for Gentoo and "i386" for everyone else
        } else if (RE2::PartialMatch(model->value(), "i[3456]86|pentium")) {
            if (os->value() == os::gentoo) {
                value = "x86";
            } else {
                value = "i386";
            }
        }

        facts.add(fact::architecture, make_value<string_value>(move(value)));
    }

    void processor_resolver::resolve_structured_processors(collection& facts)
    {
        auto processors_value = make_value<map_value>();
        unordered_set<string> cpus;
        size_t logical_count = 0;
        size_t physical_count = 0;

        directory::each_subdirectory("/sys/devices/system/cpu", [&](string const& cpu_directory) {
            ++logical_count;
            string id = trim(file::read((path(cpu_directory) / "/topology/physical_package_id").string()));
            if (id.empty() || cpus.emplace(move(id)).second) {
                // Haven't seen this processor before
                ++physical_count;
            }
            return true;
        }, "^cpu\\d+$");

        // To determine model information, parse /proc/cpuinfo
        auto processor_list = make_value<array_value>();
        bool have_counts = logical_count > 0;
        string id;
        file::each_line("/proc/cpuinfo", [&](string& line) {
            // Split the line on colon
            auto pos = line.find(":");
            if (pos == string::npos) {
                return true;
            }
            string key = trim(line.substr(0, pos));
            string value = trim(line.substr(pos + 1));

            if (key == "processor") {
                // Start of a logical processor
                id = move(value);
                if (!have_counts) {
                    ++logical_count;
                }
            } else if (!id.empty() && key == "model name") {
                // Add the model name fact for this logical processor
                processor_list->add(make_value<string_value>(move(value)));
            } else if (!have_counts && key == "physical id" && cpus.emplace(move(value)).second) {
                // Couldn't determine physical count from sysfs, but CPU topology is present, so use it
                ++physical_count;
            }
            return true;
        });

        // Add the model facts
        if (processor_list->size() > 0) {
            processors_value->add("models", move(processor_list));
        }
        // Add the count facts
        if (logical_count > 0) {
            processors_value->add("count", make_value<integer_value>(logical_count));
        }
        if (physical_count > 0) {
            processors_value->add("physicalcount", make_value<integer_value>(physical_count));
        }

        if (!processors_value->empty()) {
            facts.add(fact::processors, move(processors_value));
        }
    }

}}}  // namespace facter::facts::linux
