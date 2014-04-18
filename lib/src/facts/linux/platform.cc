#include <facts/fact_map.hpp>
#include <facts/posix/kernel_resolver.hpp>
#include <facts/linux/operating_system_resolver.hpp>
#include <facts/linux/lsb_resolver.hpp>
#include <facts/linux/networking_resolver.hpp>

using namespace std;

namespace cfacter { namespace facts {

    void populate_platform_facts(fact_map& facts)
    {
        facts.add(make_shared<posix::kernel_resolver>());
        facts.add(make_shared<linux::operating_system_resolver>());
        facts.add(make_shared<linux::lsb_resolver>());
        facts.add(make_shared<linux::networking_resolver>());
    }

}}  // namespace cfacter::facts
