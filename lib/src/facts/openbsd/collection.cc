#include <facter/facts/collection.hpp>
#include <internal/facts/bsd/filesystem_resolver.hpp>
#include <internal/facts/bsd/uptime_resolver.hpp>
#include <internal/facts/glib/load_average_resolver.hpp>
#include <internal/facts/openbsd/dmi_resolver.hpp>
#include <internal/facts/openbsd/memory_resolver.hpp>
#include <internal/facts/openbsd/networking_resolver.hpp>
#include <internal/facts/openbsd/virtualization_resolver.hpp>
#include <internal/facts/openbsd/processor_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/posix/kernel_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>
#include <internal/facts/resolvers/operating_system_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts(set<string> const& blocklist)
    {
        add(make_shared<posix::kernel_resolver>());
        add(make_shared<resolvers::operating_system_resolver>());
        add(make_shared<bsd::uptime_resolver>());
        add(make_shared<bsd::filesystem_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<glib::load_average_resolver>());
        add(make_shared<openbsd::networking_resolver>());
        add(make_shared<openbsd::dmi_resolver>());
        add(make_shared<openbsd::memory_resolver>());
        add(make_shared<openbsd::virtualization_resolver>());
        add(make_shared<openbsd::processor_resolver>());
    }

}}  // namespace facter::facts
