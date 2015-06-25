#include <catch.hpp>
#include <internal/facts/resolvers/disk_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

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

SCENARIO("using the disk resolver") {
    collection_fixture facts;
    auto resolver = make_shared<test_disk_resolver>();
    facts.add(resolver);
    GIVEN("no disks present") {
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    GIVEN("five present disks") {
        const unsigned int count = 5;
        for (unsigned int i = 0; i < count; ++i) {
            string num = to_string(i);
            resolver->add_disk("disk" + num, "vendor" + num, "model" + num, "product" + num, 12345 + i);
        }
        THEN("a structured fact should be added") {
            auto disks = facts.get<map_value>(fact::disks);
            REQUIRE(disks);
            REQUIRE(disks->size() == count);

            for (unsigned int i = 0; i < count; ++i) {
                string num = to_string(i);

                auto disk = disks->get<map_value>("disk" + num);
                REQUIRE(disk);
                REQUIRE(disk->size() == 5u);

                auto model = disk->get<string_value>("model");
                REQUIRE(model);
                REQUIRE(model->value() == "model" + num);

                auto product = disk->get<string_value>("product");
                REQUIRE(product);
                REQUIRE(product->value() == "product" + num);

                auto size = disk->get<string_value>("size");
                REQUIRE(size);
                REQUIRE(size->value() == "12.06 KiB");

                auto size_bytes = disk->get<integer_value>("size_bytes");
                REQUIRE(size_bytes);
                REQUIRE(size_bytes->value() == 12345 + i);

                auto vendor = disk->get<string_value>("vendor");
                REQUIRE(vendor);
                REQUIRE(vendor->value() == "vendor" + num);
            }
        }
        THEN("flat facts should be added") {
            string names;
            for (unsigned int i = 0; i < count; ++i) {
                string num = to_string(i);

                auto model = facts.get<string_value>("blockdevice_disk" + num + "_model");
                REQUIRE(model);
                REQUIRE(model->value() == "model" + num);

                auto size = facts.get<integer_value>("blockdevice_disk" + num + "_size");
                REQUIRE(size);
                REQUIRE(size->value() == 12345 + i);

                auto vendor = facts.get<string_value>("blockdevice_disk" + num + "_vendor");
                REQUIRE(vendor);
                REQUIRE(vendor->value() == "vendor" + num);

                if (names.size() > 0u) {
                    names += ",";
                }
                names += "disk" + num;
            }
            auto devices = facts.get<string_value>(fact::block_devices);
            REQUIRE(devices);
            REQUIRE(devices->value() == names);
        }
    }
}
