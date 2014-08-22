#include <facter/facts/collection.hpp>
#include <facter/facts/solaris/kernel_resolver.hpp>
#include <facter/facts/posix/ssh_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<solaris::kernel_resolver>());
        add(make_shared<posix::ssh_resolver>());
    }

}}  // namespace facter::facts
