#include <catch.hpp>
#include <internal/facts/resolvers/memory_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_memory_resolver : memory_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_memory_resolver : memory_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.swap_encryption = encryption_status::encrypted;
        result.mem_total = 10 * 1024 * 1024;
        result.mem_free = 5 * 1024 * 1024;
        result.swap_total = 20 * 1024 * 1024;
        result.swap_free = 4 * 1024 * 1024;
        return result;
    }
};

SCENARIO("using the memory resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_memory_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_memory_resolver>());
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 10u);
            auto memory = facts.get<map_value>(fact::memory);
            REQUIRE(memory);
            auto info = memory->get<map_value>("swap");
            REQUIRE(info);
            REQUIRE(info->size() == 8u);
            auto available = info->get<string_value>("available");
            REQUIRE(available);
            REQUIRE(available->value() == "4.00 MiB");
            auto available_bytes = info->get<integer_value>("available_bytes");
            REQUIRE(available_bytes);
            REQUIRE(available_bytes->value() == 4194304);
            auto capacity = info->get<string_value>("capacity");
            REQUIRE(capacity);
            REQUIRE(capacity->value() == "80.00%");
            auto encrypted = info->get<boolean_value>("encrypted");
            REQUIRE(encrypted);
            REQUIRE(encrypted->value());
            auto total = info->get<string_value>("total");
            REQUIRE(total);
            REQUIRE(total->value() == "20.00 MiB");
            auto total_bytes = info->get<integer_value>("total_bytes");
            REQUIRE(total_bytes);
            REQUIRE(total_bytes->value() == 20971520);
            auto used = info->get<string_value>("used");
            REQUIRE(used);
            REQUIRE(used->value() == "16.00 MiB");
            auto used_bytes = info->get<integer_value>("used_bytes");
            REQUIRE(used_bytes);
            REQUIRE(used_bytes->value() == 16777216);
            info = memory->get<map_value>("system");
            REQUIRE(info);
            REQUIRE(info->size() == 7u);
            available = info->get<string_value>("available");
            REQUIRE(available);
            REQUIRE(available->value() == "5.00 MiB");
            available_bytes = info->get<integer_value>("available_bytes");
            REQUIRE(available_bytes);
            REQUIRE(available_bytes->value() == 5242880);
            capacity = info->get<string_value>("capacity");
            REQUIRE(capacity);
            REQUIRE(capacity->value() == "50.00%");
            total = info->get<string_value>("total");
            REQUIRE(total);
            REQUIRE(total->value() == "10.00 MiB");
            total_bytes = info->get<integer_value>("total_bytes");
            REQUIRE(total_bytes);
            REQUIRE(total_bytes->value() == 10485760);
            used = info->get<string_value>("used");
            REQUIRE(used);
            REQUIRE(used->value() == "5.00 MiB");
            used_bytes = info->get<integer_value>("used_bytes");
            REQUIRE(used_bytes);
            REQUIRE(used_bytes->value() == 5242880);
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 10u);
            auto memoryfree = facts.get<string_value>(fact::memoryfree);
            REQUIRE(memoryfree);
            REQUIRE(memoryfree->value() == "5.00 MiB");
            auto memoryfree_mb = facts.get<double_value>(fact::memoryfree_mb);
            REQUIRE(memoryfree_mb);
            REQUIRE(memoryfree_mb->value() == Approx(5.0));
            auto memorysize = facts.get<string_value>(fact::memorysize);
            REQUIRE(memorysize);
            REQUIRE(memorysize->value() == "10.00 MiB");
            auto memorysize_mb = facts.get<double_value>(fact::memorysize_mb);
            REQUIRE(memorysize_mb);
            REQUIRE(memorysize_mb->value() == Approx(10.0));
            auto swapencrypted = facts.get<boolean_value>(fact::swapencrypted);
            REQUIRE(swapencrypted);
            REQUIRE(swapencrypted->value());
            auto swapfree = facts.get<string_value>(fact::swapfree);
            REQUIRE(swapfree);
            REQUIRE(swapfree->value() == "4.00 MiB");
            auto swapfree_mb = facts.get<double_value>(fact::swapfree_mb);
            REQUIRE(swapfree_mb);
            REQUIRE(swapfree_mb->value() == Approx(4.0));
            auto swapsize = facts.get<string_value>(fact::swapsize);
            REQUIRE(swapsize);
            REQUIRE(swapsize->value() == "20.00 MiB");
            auto swapsize_mb = facts.get<double_value>(fact::swapsize_mb);
            REQUIRE(swapsize_mb);
            REQUIRE(swapsize_mb->value() == Approx(20.0));
        }
    }
}
