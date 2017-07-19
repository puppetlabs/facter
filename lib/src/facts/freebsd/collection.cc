#include <facter/facts/collection.hpp>
#include <internal/facts/bsd/filesystem_resolver.hpp>
#include <internal/facts/bsd/uptime_resolver.hpp>
#include <internal/facts/glib/load_average_resolver.hpp>
#include <internal/facts/freebsd/processor_resolver.hpp>
#include <internal/facts/freebsd/dmi_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/posix/kernel_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>
#include <internal/facts/freebsd/operating_system_resolver.hpp>
#include <internal/facts/freebsd/networking_resolver.hpp>
#include <internal/facts/freebsd/zfs_resolver.hpp>
#include <internal/facts/freebsd/zpool_resolver.hpp>
#include <internal/facts/freebsd/virtualization_resolver.hpp>
#include <internal/facts/freebsd/memory_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<posix::kernel_resolver>());
        add(make_shared<freebsd::operating_system_resolver>());
        add(make_shared<freebsd::networking_resolver>());
        add(make_shared<bsd::uptime_resolver>());
        add(make_shared<bsd::filesystem_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<glib::load_average_resolver>());
        add(make_shared<freebsd::processor_resolver>());
        add(make_shared<freebsd::dmi_resolver>());
        add(make_shared<freebsd::zfs_resolver>());
        add(make_shared<freebsd::zpool_resolver>());
        add(make_shared<freebsd::virtualization_resolver>());
        add(make_shared<freebsd::memory_resolver>());
    }

}}  // namespace facter::facts
