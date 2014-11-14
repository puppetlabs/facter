#include <facter/facts/collection.hpp>
#include <facter/facts/posix/kernel_resolver.hpp>
#include <facter/facts/osx/operating_system_resolver.hpp>
#include <facter/facts/osx/networking_resolver.hpp>
#include <facter/facts/osx/processor_resolver.hpp>
#include <facter/facts/osx/dmi_resolver.hpp>
#include <facter/facts/osx/system_profiler_resolver.hpp>
#include <facter/facts/osx/virtualization_resolver.hpp>
#include <facter/facts/bsd/uptime_resolver.hpp>
#include <facter/facts/posix/ssh_resolver.hpp>
#include <facter/facts/posix/identity_resolver.hpp>
#include <facter/facts/posix/timezone_resolver.hpp>
#include <facter/facts/bsd/filesystem_resolver.hpp>
#include <facter/facts/osx/memory_resolver.hpp>
#include <facter/facts/resolvers/ruby_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<posix::kernel_resolver>());
        add(make_shared<osx::operating_system_resolver>());
        add(make_shared<bsd::uptime_resolver>());
        add(make_shared<osx::networking_resolver>());
        add(make_shared<osx::processor_resolver>());
        add(make_shared<osx::dmi_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<osx::system_profiler_resolver>());
        add(make_shared<osx::virtualization_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
        add(make_shared<bsd::filesystem_resolver>());
        add(make_shared<osx::memory_resolver>());
        add(make_shared<resolvers::ruby_resolver>());
    }

}}  // namespace facter::facts
