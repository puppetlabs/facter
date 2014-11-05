#include <facter/facts/collection.hpp>
#include <facter/facts/posix/kernel_resolver.hpp>
#include <facter/facts/posix/identity_resolver.hpp>
#include <facter/facts/linux/operating_system_resolver.hpp>
#include <facter/facts/linux/networking_resolver.hpp>
#include <facter/facts/linux/disk_resolver.hpp>
#include <facter/facts/linux/dmi_resolver.hpp>
#include <facter/facts/linux/processor_resolver.hpp>
#include <facter/facts/linux/uptime_resolver.hpp>
#include <facter/facts/linux/selinux_resolver.hpp>
#include <facter/facts/linux/virtualization_resolver.hpp>
#include <facter/facts/posix/ssh_resolver.hpp>
#include <facter/facts/posix/timezone_resolver.hpp>
#include <facter/facts/linux/filesystem_resolver.hpp>
#include <facter/facts/linux/memory_resolver.hpp>
#include <facter/facts/resolvers/ec2_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<posix::kernel_resolver>());
        add(make_shared<linux::operating_system_resolver>());
        add(make_shared<linux::networking_resolver>());
        add(make_shared<linux::disk_resolver>());
        add(make_shared<linux::dmi_resolver>());
        add(make_shared<linux::processor_resolver>());
        add(make_shared<linux::uptime_resolver>());
        add(make_shared<linux::selinux_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<linux::virtualization_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<linux::filesystem_resolver>());
        add(make_shared<linux::memory_resolver>());
        add(make_shared<resolvers::ec2_resolver>());
    }

}}  // namespace facter::facts
