#include <internal/facts/resolvers/memory_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

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

    void memory_resolver::resolve(collection& facts)
    {
        data result = collect_data(facts);

        auto value = make_value<map_value>();

        if (result.mem_total > 0) {
            uint64_t mem_used = result.mem_total - result.mem_free;

            auto stats = make_value<map_value>();
            stats->add("total", make_value<string_value>(si_string(result.mem_total)));
            stats->add("total_bytes", make_value<integer_value>(result.mem_total));
            stats->add("used", make_value<string_value>(si_string(mem_used)));
            stats->add("used_bytes", make_value<integer_value>(mem_used));
            stats->add("available", make_value<string_value>(si_string(result.mem_free)));
            stats->add("available_bytes", make_value<integer_value>(result.mem_free));
            stats->add("capacity", make_value<string_value>(percentage(mem_used, result.mem_total)));
            value->add("system", move(stats));

            // Add hidden facts
            facts.add(fact::memoryfree, make_value<string_value>(si_string(result.mem_free), true));
            facts.add(fact::memoryfree_mb, make_value<double_value>(result.mem_free / (1024.0 * 1024.0), true));
            facts.add(fact::memorysize, make_value<string_value>(si_string(result.mem_total), true));
            facts.add(fact::memorysize_mb, make_value<double_value>(result.mem_total / (1024.0 * 1024.0), true));
        }

        if (result.swap_total > 0) {
            uint64_t swap_used = result.swap_total - result.swap_free;

            auto stats = make_value<map_value>();
            stats->add("total", make_value<string_value>(si_string(result.swap_total)));
            stats->add("total_bytes", make_value<integer_value>(result.swap_total));
            stats->add("used", make_value<string_value>(si_string(swap_used)));
            stats->add("used_bytes", make_value<integer_value>(swap_used));
            stats->add("available", make_value<string_value>(si_string(result.swap_free)));
            stats->add("available_bytes", make_value<integer_value>(result.swap_free));
            stats->add("capacity", make_value<string_value>(percentage(swap_used, result.swap_total)));
            if (result.swap_encryption != encryption_status::unknown) {
                stats->add("encrypted", make_value<boolean_value>(result.swap_encryption == encryption_status::encrypted));
            }
            value->add("swap", move(stats));

            // Add hidden facts
            facts.add(fact::swapfree, make_value<string_value>(si_string(result.swap_free), true));
            facts.add(fact::swapfree_mb, make_value<double_value>(result.swap_free / (1024.0 * 1024.0), true));
            facts.add(fact::swapsize, make_value<string_value>(si_string(result.swap_total), true));
            facts.add(fact::swapsize_mb, make_value<double_value>(result.swap_total / (1024.0 * 1024.0), true));
            if (result.swap_encryption != encryption_status::unknown) {
                facts.add(fact::swapencrypted, make_value<boolean_value>(result.swap_encryption == encryption_status::encrypted, true));
            }
        }

        if (!value->empty()) {
            facts.add(fact::memory, move(value));
        }
    }

}}}  // namespace facter::facts::resolvers
