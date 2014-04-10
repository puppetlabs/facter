#include <facts/posix/kernel_resolver.hpp>
#include <facts/posix/operating_system_resolver.hpp>
#include <facts/string_value.hpp>
#include <facts/fact_map.hpp>

using namespace std;

namespace cfacter { namespace facts { namespace posix {

    void operating_system_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all operating system related facts
        resolve_operating_system(facts);
    }

    void operating_system_resolver::resolve_operating_system(fact_map& facts)
    {
        // Default to the same value as the kernel
        auto kernel = facts.get<string_value>(kernel_resolver::kernel_name);
        if (!kernel) {
            return;
        }

        facts.add(operating_system_name, make_value<string_value>(kernel->value()));
    }

}}}  // namespace cfacter::facts::posix
