#include <facts/fact_map.hpp>
#include <facts/posix/kernel_resolver.hpp>
#include <facts/linux/operating_system_resolver.hpp>
#include <facts/linux/lsb_resolver.hpp>

using namespace std;

namespace cfacter { namespace facts {

    void populate_platform_facts(fact_map& facts)
    {
        facts.add_resolver<posix::kernel_resolver>();
        facts.add_resolver<linux::operating_system_resolver>();
        facts.add_resolver<linux::lsb_resolver>();
    }

}}  // namespace cfacter::facts
