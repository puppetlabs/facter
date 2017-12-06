#include <facter/facts/collection.hpp>
#include <internal/facts/linux/kernel_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/linux/operating_system_resolver.hpp>
#include <internal/facts/linux/networking_resolver.hpp>
#include <internal/facts/linux/disk_resolver.hpp>
#include <internal/facts/linux/dmi_resolver.hpp>
#include <internal/facts/linux/processor_resolver.hpp>
#include <internal/facts/linux/uptime_resolver.hpp>
#include <internal/facts/linux/virtualization_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>
#include <internal/facts/linux/filesystem_resolver.hpp>
#include <internal/facts/linux/memory_resolver.hpp>
#include <internal/facts/glib/load_average_resolver.hpp>
#include <internal/facts/posix/xen_resolver.hpp>
#include <internal/facts/linux/fips_resolver.hpp>


using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<linux::kernel_resolver>());
        add(make_shared<linux::operating_system_resolver>());
        add(make_shared<linux::networking_resolver>());
        add(make_shared<linux::disk_resolver>());
        add(make_shared<linux::dmi_resolver>());
        add(make_shared<linux::processor_resolver>());
        add(make_shared<linux::uptime_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<linux::virtualization_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<linux::filesystem_resolver>());
        add(make_shared<linux::memory_resolver>());
        add(make_shared<glib::load_average_resolver>());
        add(make_shared<posix::xen_resolver>());
        add(make_shared<linux::fips_resolver>());
    }

}}  // namespace facter::facts
