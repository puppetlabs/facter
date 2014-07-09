#include <facter/facts/fact_map.hpp>
#include <facter/facts/posix/kernel_resolver.hpp>
#include <facter/facts/posix/operating_system_resolver.hpp>
#include <facter/facts/bsd/uptime_resolver.hpp>
#include <facter/facts/posix/ssh_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void populate_platform_facts(fact_map& facts)
    {
        facts.add(make_shared<posix::kernel_resolver>());
        facts.add(make_shared<posix::operating_system_resolver>());
        facts.add(make_shared<bsd::uptime_resolver>());
        facts.add(make_shared<posix::ssh_resolver>());
    }

}}  // namespace facter::facts
