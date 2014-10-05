#include <gmock/gmock.h>
#include <facter/facts/resolvers/disk_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct test_disk_resolver : disk_resolver
{
    void add_disk(string name, string vendor, string model, string product, uint64_t size)
    {
        disk d;
        d.name = move(name);
        d.vendor = move(vendor);
        d.model = move(model);
        d.product = move(product);
        d.size = size;
        disks.emplace_back(move(d));
    }

 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.disks = move(disks);
        return result;
    }

 private:
    vector<disk> disks;
};

TEST(facter_facts_resolvers_disk_resolver, empty)
{
    collection facts;
    facts.add(make_shared<test_disk_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_disk_resolver, disks)
{
    collection facts;
    auto resolver = make_shared<test_disk_resolver>();

    const unsigned int count = 5;

    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);
        resolver->add_disk("disk" + num, "vendor" + num, "model" + num, "product" + num, 12345 + i);
    }

    facts.add(move(resolver));
    ASSERT_EQ(2u + (3u * count), facts.size());

    string names;
    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);

        auto model = facts.get<string_value>("blockdevice_disk" + num + "_model");
        ASSERT_NE(nullptr, model);
        ASSERT_EQ("model" + num, model->value());

        auto size = facts.get<integer_value>("blockdevice_disk" + num + "_size");
        ASSERT_NE(nullptr, size);
        ASSERT_EQ(12345 + i, size->value());

        auto vendor = facts.get<string_value>("blockdevice_disk" + num + "_vendor");
        ASSERT_NE(nullptr, vendor);
        ASSERT_EQ("vendor" + num, vendor->value());

        if (names.size() > 0) {
            names += ",";
        }
        names += "disk" + num;
    }

    auto devices = facts.get<string_value>(fact::block_devices);
    ASSERT_NE(nullptr, devices);
    ASSERT_EQ(names, devices->value());

    auto disks = facts.get<map_value>(fact::disks);
    ASSERT_NE(nullptr, disks);
    ASSERT_EQ(count, disks->size());

    for (unsigned int i = 0; i < count; ++i) {
        string num = to_string(i);

        auto disk = disks->get<map_value>("disk" + num);
        ASSERT_NE(nullptr, disk);
        ASSERT_EQ(5u, disk->size());

        auto model = disk->get<string_value>("model");
        ASSERT_NE(nullptr, model);
        ASSERT_EQ("model" + num, model->value());

        auto product = disk->get<string_value>("product");
        ASSERT_NE(nullptr, product);
        ASSERT_EQ("product" + num, product->value());

        auto size = disk->get<string_value>("size");
        ASSERT_NE(nullptr, size);
        ASSERT_EQ("12.06 KiB", size->value());

        auto size_bytes = disk->get<integer_value>("size_bytes");
        ASSERT_NE(nullptr, size_bytes);
        ASSERT_EQ(12345 + i, size_bytes->value());

        auto vendor = disk->get<string_value>("vendor");
        ASSERT_NE(nullptr, vendor);
        ASSERT_EQ("vendor" + num, vendor->value());
    }
}
