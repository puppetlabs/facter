#include <internal/facts/resolvers/filesystem_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

    filesystem_resolver::filesystem_resolver() :
        resolver(
            "file system",
            {
                fact::mountpoints,
                fact::filesystems,
                fact::partitions
            })
    {
    }

    void filesystem_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        // Populate the mountpoints fact
        if (!data.mountpoints.empty()) {
            auto mountpoints = make_value<map_value>();
            for (auto& mountpoint : data.mountpoints) {
                if (mountpoint.name.empty()) {
                    continue;
                }

                uint64_t used = mountpoint.size - mountpoint.available;

                auto value = make_value<map_value>();

                if (!mountpoint.filesystem.empty()) {
                    value->add("filesystem", make_value<string_value>(move(mountpoint.filesystem)));
                }
                if (!mountpoint.device.empty()) {
                    value->add("device", make_value<string_value>(move(mountpoint.device)));
                }
                value->add("size_bytes", make_value<integer_value>(mountpoint.size));
                value->add("size", make_value<string_value>(si_string(mountpoint.size)));
                value->add("available_bytes", make_value<integer_value>(mountpoint.available));
                value->add("available", make_value<string_value>(si_string(mountpoint.available)));
                value->add("used_bytes", make_value<integer_value>(used));
                value->add("used", make_value<string_value>(si_string(used)));
                value->add("capacity", make_value<string_value>(percentage(used, mountpoint.size)));

                if (!mountpoint.options.empty()) {
                    auto options = make_value<array_value>();
                    for (auto &option : mountpoint.options) {
                        options->add(make_value<string_value>(move(option)));
                    }
                    value->add("options", move(options));
                }

                mountpoints->add(move(mountpoint.name), move(value));
            }
            facts.add(fact::mountpoints, move(mountpoints));
        }

        // Populate the filesystems fact
        if (!data.filesystems.empty()) {
            facts.add(fact::filesystems, make_value<string_value>(boost::join(data.filesystems, ",")));
        }

        // Populate the partitions fact
        if (!data.partitions.empty()) {
            auto partitions = make_value<map_value>();
            for (auto& partition : data.partitions) {
                if (partition.name.empty()) {
                    continue;
                }

                auto value = make_value<map_value>();

                if (!partition.filesystem.empty()) {
                    value->add("filesystem", make_value<string_value>(move(partition.filesystem)));
                }
                if (!partition.mount.empty()) {
                    value->add("mount", make_value<string_value>(move(partition.mount)));
                }
                if (!partition.label.empty()) {
                    value->add("label", make_value<string_value>(move(partition.label)));
                }
                if (!partition.partition_label.empty()) {
                    value->add("partlabel", make_value<string_value>(move(partition.partition_label)));
                }
                if (!partition.uuid.empty()) {
                    value->add("uuid", make_value<string_value>(move(partition.uuid)));
                }
                if (!partition.partition_uuid.empty()) {
                    value->add("partuuid", make_value<string_value>(move(partition.partition_uuid)));
                }
                value->add("size_bytes", make_value<integer_value>(partition.size));
                value->add("size", make_value<string_value>(si_string(partition.size)));

                partitions->add(move(partition.name), move(value));
            }
            facts.add(fact::partitions, move(partitions));
        }
    }

}}}  // namespace facter::facts::resolvers
