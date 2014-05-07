#include <facter/facts/fact_map.hpp>
#include <facter/facts/posix/kernel_resolver.hpp>
#include <facter/facts/linux/operating_system_resolver.hpp>
#include <facter/facts/linux/lsb_resolver.hpp>
#include <facter/facts/linux/networking_resolver.hpp>
#include <facter/facts/linux/block_device_resolver.hpp>
#include <facter/facts/linux/dmi_resolver.hpp>
#include <facter/facts/linux/processor_resolver.hpp>
#include <facter/facts/linux/uptime_resolver.hpp>
#include <facter/facts/linux/selinux_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void populate_platform_facts(fact_map& facts)
    {
        facts.add(make_shared<posix::kernel_resolver>());
        facts.add(make_shared<linux::operating_system_resolver>());
        facts.add(make_shared<linux::lsb_resolver>());
        facts.add(make_shared<linux::networking_resolver>());
        facts.add(make_shared<linux::block_device_resolver>());
        facts.add(make_shared<linux::dmi_resolver>());
        facts.add(make_shared<linux::processor_resolver>());
        facts.add(make_shared<linux::uptime_resolver>());
        facts.add(make_shared<linux::selinux_resolver>());
    }

}}  // namespace facter::facts
