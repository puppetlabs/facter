#include <facter/facts/collection.hpp>
#include <internal/facts/posix/kernel_resolver.hpp>
#include <internal/facts/osx/operating_system_resolver.hpp>
#include <internal/facts/osx/networking_resolver.hpp>
#include <internal/facts/osx/processor_resolver.hpp>
#include <internal/facts/osx/dmi_resolver.hpp>
#include <internal/facts/osx/system_profiler_resolver.hpp>
#include <internal/facts/osx/virtualization_resolver.hpp>
#include <internal/facts/bsd/uptime_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>
#include <internal/facts/bsd/filesystem_resolver.hpp>
#include <internal/facts/osx/memory_resolver.hpp>
#include <internal/facts/glib/load_average_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts(set<string> const& blocklist)
    {
        if (!blocklist.count("kernel")) {
            add(make_shared<posix::kernel_resolver>());
        }
        if (!blocklist.count("os")) {
            add(make_shared<osx::operating_system_resolver>());
        }
        if (!blocklist.count("system_uptime")) {
            add(make_shared<bsd::uptime_resolver>());
        }
        if (!blocklist.count("networking")) {
            add(make_shared<osx::networking_resolver>());
        }
        if (!blocklist.count("processors")) {
            add(make_shared<osx::processor_resolver>());
        }
        if (!blocklist.count("dmi")) {
            add(make_shared<osx::dmi_resolver>());
        }
        if (!blocklist.count("ssh")) {
            add(make_shared<posix::ssh_resolver>());
        }
        if (!blocklist.count("system_porfiler")) {
            add(make_shared<osx::system_profiler_resolver>());
        }
        if (!blocklist.count("virtual")) {
            add(make_shared<osx::virtualization_resolver>());
        }
        if (!blocklist.count("identity")) {
            add(make_shared<posix::identity_resolver>());
        }
        if (!blocklist.count("timezone")) {
            add(make_shared<posix::timezone_resolver>());
        }
        if (!blocklist.count("filesystems")) {
            add(make_shared<bsd::filesystem_resolver>());
        }
        if (!blocklist.count("memory")) {
            add(make_shared<osx::memory_resolver>());
        }
        if (!blocklist.count("load_averages")) {
            add(make_shared<glib::load_average_resolver>());
        }
    }

}}  // namespace facter::facts
