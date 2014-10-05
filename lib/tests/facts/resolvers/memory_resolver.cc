#include <gmock/gmock.h>
#include <facter/facts/resolvers/memory_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

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

TEST(facter_facts_resolvers_memory_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_memory_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_memory_resolver, memory)
{
    collection facts;
    facts.add(make_shared<test_memory_resolver>());
    ASSERT_EQ(10u, facts.size());

    auto memoryfree = facts.get<string_value>(fact::memoryfree);
    ASSERT_NE(nullptr, memoryfree);
    ASSERT_EQ("5.00 MiB", memoryfree->value());

    auto memoryfree_mb = facts.get<double_value>(fact::memoryfree_mb);
    ASSERT_NE(nullptr, memoryfree_mb);
    ASSERT_DOUBLE_EQ(5.0, memoryfree_mb->value());

    auto memorysize = facts.get<string_value>(fact::memorysize);
    ASSERT_NE(nullptr, memorysize);
    ASSERT_EQ("10.00 MiB", memorysize->value());

    auto memorysize_mb = facts.get<double_value>(fact::memorysize_mb);
    ASSERT_NE(nullptr, memorysize_mb);
    ASSERT_DOUBLE_EQ(10.0, memorysize_mb->value());

    auto swapencrypted = facts.get<boolean_value>(fact::swapencrypted);
    ASSERT_NE(nullptr, swapencrypted);
    ASSERT_TRUE(swapencrypted->value());

    auto swapfree = facts.get<string_value>(fact::swapfree);
    ASSERT_NE(nullptr, swapfree);
    ASSERT_EQ("4.00 MiB", swapfree->value());

    auto swapfree_mb = facts.get<double_value>(fact::swapfree_mb);
    ASSERT_NE(nullptr, swapfree_mb);
    ASSERT_DOUBLE_EQ(4.0, swapfree_mb->value());

    auto swapsize = facts.get<string_value>(fact::swapsize);
    ASSERT_NE(nullptr, swapsize);
    ASSERT_EQ("20.00 MiB", swapsize->value());

    auto swapsize_mb = facts.get<double_value>(fact::swapsize_mb);
    ASSERT_NE(nullptr, swapsize_mb);
    ASSERT_DOUBLE_EQ(20.0, swapsize_mb->value());

    auto memory = facts.get<map_value>(fact::memory);
    ASSERT_NE(nullptr, memory);

    auto info = memory->get<map_value>("swap");
    ASSERT_NE(nullptr, info);
    ASSERT_EQ(8u, info->size());

    auto available = info->get<string_value>("available");
    ASSERT_NE(nullptr, available);
    ASSERT_EQ("4.00 MiB", available->value());

    auto available_bytes = info->get<integer_value>("available_bytes");
    ASSERT_NE(nullptr, available_bytes);
    ASSERT_EQ(4194304, available_bytes->value());

    auto capacity = info->get<string_value>("capacity");
    ASSERT_NE(nullptr, capacity);
    ASSERT_EQ("80.00%", capacity->value());

    auto encrypted = info->get<boolean_value>("encrypted");
    ASSERT_NE(nullptr, encrypted);
    ASSERT_TRUE(encrypted->value());

    auto total = info->get<string_value>("total");
    ASSERT_NE(nullptr, total);
    ASSERT_EQ("20.00 MiB", total->value());

    auto total_bytes = info->get<integer_value>("total_bytes");
    ASSERT_NE(nullptr, total_bytes);
    ASSERT_EQ(20971520, total_bytes->value());

    auto used = info->get<string_value>("used");
    ASSERT_NE(nullptr, used);
    ASSERT_EQ("16.00 MiB", used->value());

    auto used_bytes = info->get<integer_value>("used_bytes");
    ASSERT_NE(nullptr, used_bytes);
    ASSERT_EQ(16777216, used_bytes->value());

    info = memory->get<map_value>("system");
    ASSERT_NE(nullptr, info);
    ASSERT_EQ(7u, info->size());

    available = info->get<string_value>("available");
    ASSERT_NE(nullptr, available);
    ASSERT_EQ("5.00 MiB", available->value());

    available_bytes = info->get<integer_value>("available_bytes");
    ASSERT_NE(nullptr, available_bytes);
    ASSERT_EQ(5242880, available_bytes->value());

    capacity = info->get<string_value>("capacity");
    ASSERT_NE(nullptr, capacity);
    ASSERT_EQ("50.00%", capacity->value());

    total = info->get<string_value>("total");
    ASSERT_NE(nullptr, total);
    ASSERT_EQ("10.00 MiB", total->value());

    total_bytes = info->get<integer_value>("total_bytes");
    ASSERT_NE(nullptr, total_bytes);
    ASSERT_EQ(10485760, total_bytes->value());

    used = info->get<string_value>("used");
    ASSERT_NE(nullptr, used);
    ASSERT_EQ("5.00 MiB", used->value());

    used_bytes = info->get<integer_value>("used_bytes");
    ASSERT_NE(nullptr, used_bytes);
    ASSERT_EQ(5242880, used_bytes->value());
}
