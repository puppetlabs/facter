#include <facter/facts/collection.hpp>
#include <facter/facts/solaris/kernel_resolver.hpp>

using namespace std;

namespace facter { namespace facts {

    void collection::add_platform_facts()
    {
        add(make_shared<solaris::kernel_resolver>());
    }

}}  // namespace facter::facts
