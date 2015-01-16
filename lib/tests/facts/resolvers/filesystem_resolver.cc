#include <gmock/gmock.h>
#include <facter/facts/resolvers/filesystem_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_filesystem_resolver : filesystem_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_filesystem_resolver : filesystem_resolver
{
    void add_mountpoint(string name, string device, string filesystem, uint64_t size, uint64_t available, vector<string> options)
    {
        mountpoint mp;
        mp.name = move(name);
        mp.device = move(device);
        mp.filesystem = move(filesystem);
        mp.size = size;
        mp.available = available;
        mp.options = move(options);
        mountpoints.emplace_back(move(mp));
    }

    void add_filesystem(string filesystem)
    {
        filesystems.emplace(move(filesystem));
    }

    void add_partition(string name, string filesystem, uint64_t size, string uuid, string partuuid, string label, string partlabel, string mount)
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

TEST(facter_facts_resolvers_filesystem_resolver, empty) {
    collection facts;
    facts.add(make_shared<empty_filesystem_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_filesystem_resolver, mountpoints)
{
    collection facts;

    auto resolver = make_shared<test_filesystem_resolver>();

    const unsigned int count = 5;

    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);
        resolver->add_mountpoint("mount" + num, "device" + num, "filesystem" + num, 12345, 1000, {"option1" + num, "option2" + num, "option3" + num});
    }

    facts.add(move(resolver));
    ASSERT_EQ(1u, facts.size());

    auto mountpoints = facts.get<map_value>(fact::mountpoints);
    ASSERT_NE(nullptr, mountpoints);
    ASSERT_EQ(5u, mountpoints->size());

    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);

        auto mountpoint = mountpoints->get<map_value>("mount" + num);
        ASSERT_NE(nullptr, mountpoint);
        ASSERT_EQ(10u, mountpoint->size());

        auto available = mountpoint->get<string_value>("available");
        ASSERT_NE(nullptr, available);
        ASSERT_EQ("1000 bytes", available->value());

        auto available_bytes = mountpoint->get<integer_value>("available_bytes");
        ASSERT_NE(nullptr, available_bytes);
        ASSERT_EQ(1000, available_bytes->value());

        auto capacity = mountpoint->get<string_value>("capacity");
        ASSERT_NE(nullptr, capacity);
        ASSERT_EQ("91.90%", capacity->value());

        auto device = mountpoint->get<string_value>("device");
        ASSERT_NE(nullptr, device);
        ASSERT_EQ("device" + num, device->value());

        auto filesystem = mountpoint->get<string_value>("filesystem");
        ASSERT_NE(nullptr, filesystem);
        ASSERT_EQ("filesystem" + num, filesystem->value());

        auto options = mountpoint->get<array_value>("options");
        ASSERT_NE(nullptr, options);
        ASSERT_EQ(3u, options->size());
        ASSERT_EQ("option1" + num, options->get<string_value>(0)->value());
        ASSERT_EQ("option2" + num, options->get<string_value>(1)->value());
        ASSERT_EQ("option3" + num, options->get<string_value>(2)->value());

        auto size = mountpoint->get<string_value>("size");
        ASSERT_NE(nullptr, size);
        ASSERT_EQ("12.06 KiB", size->value());

        auto size_bytes = mountpoint->get<integer_value>("size_bytes");
        ASSERT_NE(nullptr, size_bytes);
        ASSERT_EQ(12345, size_bytes->value());

        auto used = mountpoint->get<string_value>("used");
        ASSERT_NE(nullptr, used);
        ASSERT_EQ("11.08 KiB", used->value());

        auto used_bytes = mountpoint->get<integer_value>("used_bytes");
        ASSERT_NE(nullptr, used_bytes);
        ASSERT_EQ(12345 - 1000, used_bytes->value());
    }
}

TEST(facter_facts_resolvers_filesystem_resolver, filesystems)
{
    collection facts;

    auto resolver = make_shared<test_filesystem_resolver>();

    resolver->add_filesystem("foo");
    resolver->add_filesystem("bar");
    resolver->add_filesystem("baz");

    facts.add(move(resolver));
    ASSERT_EQ(1u, facts.size());

    auto filesystems = facts.get<string_value>(fact::filesystems);
    ASSERT_NE(nullptr, filesystems);
    ASSERT_EQ("bar,baz,foo", filesystems->value());
}

TEST(facter_facts_resolvers_filesystem_resolver, partitions)
{
    collection facts;

    auto resolver = make_shared<test_filesystem_resolver>();

    const unsigned int count = 5;

    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);
        resolver->add_partition("partition" + num, "filesystem" + num, 12345 + i, "uuid" + num, "partuuid" + num, "label" + num, "partlabel" + num, "mount" + num);
    }

    facts.add(move(resolver));
    ASSERT_EQ(1u, facts.size());

    auto partitions = facts.get<map_value>(fact::partitions);
    ASSERT_NE(nullptr, partitions);

    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);

        auto partition = partitions->get<map_value>("partition" + num);
        ASSERT_NE(nullptr, partition);
        ASSERT_EQ(8u, partition->size());

        auto filesystem = partition->get<string_value>("filesystem");
        ASSERT_NE(nullptr, filesystem);
        ASSERT_EQ("filesystem" + num, filesystem->value());

        auto label = partition->get<string_value>("label");
        ASSERT_NE(nullptr, label);
        ASSERT_EQ("label" + num, label->value());

        auto partlabel = partition->get<string_value>("partlabel");
        ASSERT_NE(nullptr, partlabel);
        ASSERT_EQ("partlabel" + num, partlabel->value());

        auto mount = partition->get<string_value>("mount");
        ASSERT_NE(nullptr, mount);
        ASSERT_EQ("mount" + num, mount->value());

        auto partuuid = partition->get<string_value>("partuuid");
        ASSERT_NE(nullptr, partuuid);
        ASSERT_EQ("partuuid" + num, partuuid->value());

        auto uuid = partition->get<string_value>("uuid");
        ASSERT_NE(nullptr, uuid);
        ASSERT_EQ("uuid" + num, uuid->value());

        auto size_bytes = partition->get<integer_value>("size_bytes");
        ASSERT_NE(nullptr, size_bytes);
        ASSERT_EQ(12345 + i, size_bytes->value());

        auto size = partition->get<string_value>("size");
        ASSERT_NE(nullptr, size);
        ASSERT_EQ("12.06 KiB", size->value());
    }
}

