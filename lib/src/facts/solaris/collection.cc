#include <facter/facts/collection.hpp>
#include <internal/facts/solaris/kernel_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/solaris/operating_system_resolver.hpp>
#include <internal/facts/solaris/networking_resolver.hpp>
#include <internal/facts/solaris/processor_resolver.hpp>
#include <internal/facts/posix/uptime_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>
#include <internal/facts/solaris/filesystem_resolver.hpp>
#include <internal/facts/solaris/disk_resolver.hpp>
#include <internal/facts/solaris/dmi_resolver.hpp>
#include <internal/facts/solaris/virtualization_resolver.hpp>
#include <internal/facts/solaris/memory_resolver.hpp>
#include <internal/facts/solaris/zpool_resolver.hpp>
#include <internal/facts/solaris/zfs_resolver.hpp>
#include <internal/facts/solaris/zone_resolver.hpp>
#include <internal/facts/solaris/ldom_resolver.hpp>
#include <internal/facts/glib/load_average_resolver.hpp>
#include <internal/facts/posix/xen_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<solaris::kernel_resolver>());
        add(make_shared<solaris::operating_system_resolver>());
        add(make_shared<solaris::networking_resolver>());
        add(make_shared<solaris::processor_resolver>());
        add(make_shared<posix::uptime_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<solaris::filesystem_resolver>());
        add(make_shared<solaris::dmi_resolver>());
        add(make_shared<solaris::disk_resolver>());
        add(make_shared<solaris::virtualization_resolver>());
        add(make_shared<solaris::memory_resolver>());
        add(make_shared<glib::load_average_resolver>());
        add(make_shared<posix::xen_resolver>());

        // solaris specific
        add(make_shared<solaris::zpool_resolver>());
        add(make_shared<solaris::zfs_resolver>());
        add(make_shared<solaris::zone_resolver>());
        add(make_shared<solaris::ldom_resolver>());
    }

}}  // namespace facter::facts
