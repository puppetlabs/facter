#include <facter/facts/resolvers/disk_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

    disk_resolver::disk_resolver() :
        resolver(
            "disk",
            {
                fact::block_devices,
                fact::disks
            },
            {
                string("^") + fact::block_device + "_",
            })
    {
    }

    void disk_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        ostringstream names;
        auto disks = make_value<map_value>();
        for (auto& disk : data.disks) {
            if (disk.name.empty()) {
                continue;
            }
            auto value = make_value<map_value>();
            if (!disk.vendor.empty()) {
                // TODO: remove flat fact
                facts.add(string(fact::block_device) + "_" + disk.name + "_vendor" , make_value<string_value>(disk.vendor));
                value->add("vendor", make_value<string_value>(move(disk.vendor)));
            }
            if (!disk.model.empty()) {
                // TODO: remove flat fact
                facts.add(string(fact::block_device) + "_" + disk.name + "_model" , make_value<string_value>(disk.model));
                value->add("model", make_value<string_value>(move(disk.model)));
            }
            if (!disk.product.empty()) {
                value->add("product", make_value<string_value>(move(disk.product)));
            }
            // TODO: remove flat fact
            facts.add(string(fact::block_device) + "_" + disk.name + "_size" , make_value<integer_value>(static_cast<int64_t>(disk.size)));
            value->add("size_bytes", make_value<integer_value>(disk.size));
            value->add("size", make_value<string_value>(si_string(disk.size)));

            if (names.tellp() != 0) {
                names << ',';
            }
            names << disk.name;

            disks->add(move(disk.name), move(value));
        }

        // TODO: remove flat fact
        if (names.tellp() > 0) {
            facts.add(fact::block_devices, make_value<string_value>(names.str()));
        }

        if (!disks->empty()) {
            facts.add(fact::disks, move(disks));
        }
    }

}}}  // namespace facter::facts::resolvers
