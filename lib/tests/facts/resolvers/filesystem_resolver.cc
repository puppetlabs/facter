#include <catch.hpp>
#include <internal/facts/resolvers/filesystem_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct test_filesystem_resolver : filesystem_resolver
{
    void add_mountpoint(string name, string device, string filesystem, uint64_t size, uint64_t available, uint64_t reserved, vector<string> options)
    {
        mountpoint mp;
        mp.name = move(name);
        mp.device = move(device);
        mp.filesystem = move(filesystem);
        mp.size = size;
        mp.available = available;
        mp.free = available + reserved;
        mp.options = move(options);
        mountpoints.emplace_back(move(mp));
    }

    void add_filesystem(string filesystem)
    {
        filesystems.emplace(move(filesystem));
    }

    void add_partition(string name, string filesystem, uint64_t size, string uuid, string partuuid, string label, string partlabel, string mount, string backing_file)
    {
        partition p;
        p.name = move(name);
        p.filesystem = move(filesystem);
        p.size = size;
        p.uuid = move(uuid);
        p.partition_uuid = move(partuuid);
        p.label = move(label);
        p.partition_label = move(partlabel);
        p.mount = move(mount);
        p.backing_file = move(backing_file);
        partitions.emplace_back(move(p));
    }

 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.mountpoints = move(mountpoints);
        result.filesystems = move(filesystems);
        result.partitions = move(partitions);
        return result;
    }

    vector<mountpoint> mountpoints;
    set<string> filesystems;
    vector<partition> partitions;
};

SCENARIO("using the file system resolver") {
    collection_fixture facts;
    auto resolver = make_shared<test_filesystem_resolver>();
    facts.add(resolver);

    WHEN("data is not present") {
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("mount point data is present") {
        const unsigned int count = 5;
        for (unsigned int i = 0; i < count; ++i) {
            string num = to_string(i);
            resolver->add_mountpoint("mount" + num, "device" + num, "filesystem" + num, 12345, 1000, 0, {"option1" + num, "option2" + num, "option3" + num});
        }
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 1u);
            auto mountpoints = facts.get<map_value>(fact::mountpoints);
            REQUIRE(mountpoints);
            REQUIRE(mountpoints->size() == 5u);
            for (unsigned int i = 0; i < count; ++i) {
                string num = to_string(i);

                auto mountpoint = mountpoints->get<map_value>("mount" + num);
                REQUIRE(mountpoint);
                REQUIRE(mountpoint->size() == 10u);

                auto available = mountpoint->get<string_value>("available");
                REQUIRE(available);
                REQUIRE(available->value() == "1000 bytes");

                auto available_bytes = mountpoint->get<integer_value>("available_bytes");
                REQUIRE(available_bytes);
                REQUIRE(available_bytes->value() == 1000);

                auto capacity = mountpoint->get<string_value>("capacity");
                REQUIRE(capacity);
                REQUIRE(capacity->value() == "91.90%");

                auto device = mountpoint->get<string_value>("device");
                REQUIRE(device);
                REQUIRE(device->value() == "device" + num);

                auto filesystem = mountpoint->get<string_value>("filesystem");
                REQUIRE(filesystem);
                REQUIRE(filesystem->value() == "filesystem" + num);

                auto options = mountpoint->get<array_value>("options");
                REQUIRE(options);
                REQUIRE(options->size() == 3u);
                REQUIRE(options->get<string_value>(0)->value() == "option1" + num);
                REQUIRE(options->get<string_value>(1)->value() == "option2" + num);
                REQUIRE(options->get<string_value>(2)->value() == "option3" + num);

                auto size = mountpoint->get<string_value>("size");
                REQUIRE(size);
                REQUIRE(size->value() == "12.06 KiB");

                auto size_bytes = mountpoint->get<integer_value>("size_bytes");
                REQUIRE(size_bytes);
                REQUIRE(size_bytes->value() == 12345);

                auto used = mountpoint->get<string_value>("used");
                REQUIRE(used);
                REQUIRE(used->value() == "11.08 KiB");

                auto used_bytes = mountpoint->get<integer_value>("used_bytes");
                REQUIRE(used_bytes);
                REQUIRE(used_bytes->value() == 12345 - 1000);
            }
        }
    }
    WHEN("file system data is present") {
        resolver->add_filesystem("foo");
        resolver->add_filesystem("bar");
        resolver->add_filesystem("baz");

        THEN("a flat fact is added") {
            REQUIRE(facts.size() == 1u);
            auto filesystems = facts.get<string_value>(fact::filesystems);
            REQUIRE(filesystems);
            REQUIRE(filesystems->value() == "bar,baz,foo");
        }
    }
    WHEN("partition data is present") {
        const unsigned int count = 5;
        for (unsigned int i = 0; i < count; ++i) {
            string num = to_string(i);
            resolver->add_partition("partition" + num, "filesystem" + num, 12345 + i, "uuid" + num, "partuuid" + num, "label" + num, "partlabel" + num, "mount" + num, "file" + num);
        }
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 1u);

            auto partitions = facts.get<map_value>(fact::partitions);
            REQUIRE(partitions);

            for (unsigned int i = 0; i < count; ++i) {
                string num = to_string(i);

                auto partition = partitions->get<map_value>("partition" + num);
                REQUIRE(partition);
                REQUIRE(partition->size() == 9u);

                auto filesystem = partition->get<string_value>("filesystem");
                REQUIRE(filesystem);
                REQUIRE(filesystem->value() == "filesystem" + num);

                auto label = partition->get<string_value>("label");
                REQUIRE(label);
                REQUIRE(label->value() == "label" + num);

                auto partlabel = partition->get<string_value>("partlabel");
                REQUIRE(partlabel);
                REQUIRE(partlabel->value() == "partlabel" + num);

                auto mount = partition->get<string_value>("mount");
                REQUIRE(mount);
                REQUIRE(mount->value() == "mount" + num);

                auto partuuid = partition->get<string_value>("partuuid");
                REQUIRE(partuuid);
                REQUIRE(partuuid->value() == "partuuid" + num);

                auto uuid = partition->get<string_value>("uuid");
                REQUIRE(uuid);
                REQUIRE(uuid->value() == "uuid" + num);

                auto size_bytes = partition->get<integer_value>("size_bytes");
                REQUIRE(size_bytes);
                REQUIRE(size_bytes->value() == 12345 + i);

                auto size = partition->get<string_value>("size");
                REQUIRE(size);
                REQUIRE(size->value() == "12.06 KiB");

                auto file = partition->get<string_value>("backing_file");
                REQUIRE(file);
                REQUIRE(file->value() == "file" + num);
            }
        }
    }
}
