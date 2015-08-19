#include <facter/facts/collection.hpp>
#include <internal/facts/aix/kernel_resolver.hpp>
#include <internal/facts/aix/operating_system_resolver.hpp>
#include <internal/facts/aix/processor_resolver.hpp>
#include <internal/facts/posix/ssh_resolver.hpp>
#include <internal/facts/posix/identity_resolver.hpp>
#include <internal/facts/posix/timezone_resolver.hpp>

using namespace std;

namespace facter { namespace facts {
    void collection::add_platform_facts() {
        add(make_shared<aix::kernel_resolver>());
        add(make_shared<aix::operating_system_resolver>());
        add(make_shared<aix::processor_resolver>());
        add(make_shared<posix::ssh_resolver>());
        add(make_shared<posix::identity_resolver>());
        add(make_shared<posix::timezone_resolver>());
    }
}}  // namespace facter::facts
