#include <facts/fact_map.hpp>
#include <facts/posix/kernel_resolver.hpp>
#include <facts/posix/operating_system_resolver.hpp>

using namespace std;

namespace cfacter { namespace facts {

    void populate_platform_facts(fact_map& facts)
    {
        facts.add_resolver<posix::kernel_resolver>();
        facts.add_resolver<posix::operating_system_resolver>();
    }

}}  // namespace cfacter::facts
