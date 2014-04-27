#include <facter/facts/linux/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/posix/os.hpp>
#include <facter/util/string.hpp>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <re2/re2.h>
#include <fstream>
#include <string>
#include <unordered_set>

using namespace std;
using namespace re2;
using namespace facter::facts;
using namespace facter::facts::posix;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.linux.processor");

namespace facter { namespace facts { namespace linux {

    void processor_resolver::resolve_architecture(fact_map& facts)
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

    void processor_resolver::resolve_processors(fact_map& facts)
    {
        // For linux, we need to search through the output of /proc/cpuinfo
        ifstream cpuinfo("/proc/cpuinfo", ifstream::in);

        unordered_set<string> cpus;
        size_t logical_processor_count = 0;

        // Search through each line of output
        string line;
        string id;
        while (getline(cpuinfo, line)) {
           auto pos = line.find(":");
           string key = trim(line.substr(0, pos));
           string value = trim(line.substr(pos + 1));

           // If the key is processor, it's the start of a processor
           if (key == "processor") {
               id = move(value);
               ++logical_processor_count;
           } else if (key == "model name" && !id.empty()) {
               // Add the processor description fact
               facts.add(fact::processor + id, make_value<string_value>(move(value)));
           } else if (key == "physical id") {
               // Add the physical id to the set so we only count each one once
               cpus.emplace(move(value));
           }
        }

        // Logical count should be at least the physical count
        if (logical_processor_count < cpus.size()) {
            logical_processor_count = cpus.size();
        }

        // Add the count facts
        facts.add(fact::physical_processor_count, make_value<string_value>(to_string(cpus.size())));
        facts.add(fact::processor_count, make_value<string_value>(to_string(logical_processor_count)));
    }

}}}  // namespace facter::facts::linux
