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

    void kernel_resolver::resolve_facts(collection& facts)
    {
        struct utsname name;
        memset(&name, 0, sizeof(name));
        // Unlike POSIX, solaris specifies that a non negative value is
        // returned on success.
        if (uname(&name) < 0) {
            LOG_WARNING("uname failed: %1% (%2%): kernel facts are unavailable.", strerror(errno), errno);
            return;
        }
        // Resolve all kernel-related facts
        resolve_kernel(facts, name);
        resolve_kernel_release(facts, name);
        resolve_kernel_version(facts);
        resolve_kernel_major_version(facts);
    }

}}}  // namespace facter::facts::solaris
