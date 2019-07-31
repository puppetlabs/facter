#include <facter/facts/collection.hpp>
#include <internal/facts/aix/disk_resolver.hpp>
#include <internal/facts/aix/filesystem_resolver.hpp>
#include <internal/facts/aix/kernel_resolver.hpp>
#include <internal/facts/aix/load_average_resolver.hpp>
#include <internal/facts/aix/memory_resolver.hpp>
#include <internal/facts/aix/nim_resolver.hpp>
#include <internal/facts/aix/networking_resolver.hpp>
#include <internal/facts/aix/operating_system_resolver.hpp>
#include <internal/facts/aix/processor_resolver.hpp>
#include <internal/facts/aix/serial_number_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>
#include <internal/facts/posix/uptime_resolver.hpp>

using namespace std;

namespace facter { namespace facts {
    void collection::add_platform_facts() {
        add(make_shared<aix::disk_resolver>());
        add(make_shared<aix::filesystem_resolver>());
        add(make_shared<aix::kernel_resolver>());
        add(make_shared<aix::load_average_resolver>());
        add(make_shared<aix::memory_resolver>());
        add(make_shared<aix::networking_resolver>());
        add(make_shared<aix::nim_resolver>());
        add(make_shared<aix::operating_system_resolver>());
        add(make_shared<aix::processor_resolver>());
        add(make_shared<aix::serial_number_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<posix::uptime_resolver>());
    }
}}  // namespace facter::facts
