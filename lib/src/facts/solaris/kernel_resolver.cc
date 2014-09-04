#include <facter/facts/solaris/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <cstring>

using namespace std;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.solaris.kernel");

namespace facter { namespace facts { namespace solaris {

    void kernel_resolver::resolve_kernel_version(collection& facts, struct utsname const& name)
    {
        facts.add(fact::kernel_version, make_value<string_value>(name.version));
    }

    void kernel_resolver::resolve_kernel_major_version(collection& facts, struct utsname const& name)
    {
        facts.add(fact::kernel_major_version, make_value<string_value>(name.version));
    }

}}}  // namespace facter::facts::solaris
