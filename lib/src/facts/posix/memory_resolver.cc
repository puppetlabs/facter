#include <facter/facts/posix/memory_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace posix {

    memory_resolver::memory_resolver() :
        resolver(
            "memory",
            {
                fact::memory,
                fact::memoryfree,
                fact::memoryfree_mb,
                fact::memorysize,
                fact::memorysize_mb,
                fact::swapfree,
                fact::swapfree_mb,
                fact::swapsize,
                fact::swapsize_mb,
                fact::swapencrypted
            })
    {
    }

    void memory_resolver::resolve_facts(collection& facts)
    {
        uint64_t mem_free = 0;
        uint64_t mem_total = 0;
        uint64_t swap_free = 0;
        uint64_t swap_total = 0;

        if (!get_memory_statistics(facts, mem_free, mem_total, swap_free, swap_total)) {
            return;
        }

        auto swap_encryption = get_swap_encryption_status();

        uint64_t mem_used = mem_total - mem_free;
        uint64_t swap_used = swap_total - swap_free;

        auto value = make_value<map_value>();

        auto mem_stats = make_value<map_value>();
        mem_stats->add("total", make_value<string_value>(si_string(mem_total)));
        mem_stats->add("total_bytes", make_value<integer_value>(mem_total));
        mem_stats->add("used", make_value<string_value>(si_string(mem_used)));
        mem_stats->add("used_bytes", make_value<integer_value>(mem_used));
        mem_stats->add("available", make_value<string_value>(si_string(mem_free)));
        mem_stats->add("available_bytes", make_value<integer_value>(mem_free));
        mem_stats->add("capacity", make_value<string_value>(percentage(mem_used, mem_total)));
        value->add("ram", move(mem_stats));

        auto swap_stats = make_value<map_value>();
        swap_stats->add("total", make_value<string_value>(si_string(swap_total)));
        swap_stats->add("total_bytes", make_value<integer_value>(swap_total));
        swap_stats->add("used", make_value<string_value>(si_string(swap_used)));
        swap_stats->add("used_bytes", make_value<integer_value>(swap_used));
        swap_stats->add("available", make_value<string_value>(si_string(swap_free)));
        swap_stats->add("available_bytes", make_value<integer_value>(swap_free));
        swap_stats->add("capacity", make_value<string_value>(percentage(swap_used, swap_total)));
        if (swap_encryption != encryption_status::unknown) {
            swap_stats->add("encrypted", make_value<boolean_value>(swap_encryption == encryption_status::encrypted));
        }
        value->add("swap", move(swap_stats));

        facts.add(fact::memory, move(value));

        // Add the "flat" facts
        facts.add(fact::memoryfree, make_value<string_value>(si_string(mem_free)));
        facts.add(fact::memoryfree_mb, make_value<double_value>(mem_free / (1024.0 * 1024.0)));
        facts.add(fact::memorysize, make_value<string_value>(si_string(mem_total)));
        facts.add(fact::memorysize_mb, make_value<double_value>(mem_total / (1024.0 * 1024.0)));
        facts.add(fact::swapfree, make_value<string_value>(si_string(swap_free)));
        facts.add(fact::swapfree_mb, make_value<double_value>(swap_free / (1024.0 * 1024.0)));
        facts.add(fact::swapsize, make_value<string_value>(si_string(swap_total)));
        facts.add(fact::swapsize_mb, make_value<double_value>(swap_total / (1024.0 * 1024.0)));
        if (swap_encryption != encryption_status::unknown) {
            facts.add(fact::swapencrypted, make_value<boolean_value>(swap_encryption == encryption_status::encrypted));
        }
    }

    bool memory_resolver::get_memory_statistics(
            collection& facts,
            uint64_t& mem_free,
            uint64_t& mem_total,
            uint64_t& swap_free,
            uint64_t& swap_total)
    {
        return false;
    }

    memory_resolver::encryption_status memory_resolver::get_swap_encryption_status()
    {
        return encryption_status::unknown;
    }

}}}  // namespace facter::facts::posix
