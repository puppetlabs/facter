#include <internal/facts/solaris/kernel_resolver.hpp>
#include <internal/util/version_parsing.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/utsname.h>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace solaris {

    kernel_resolver::data kernel_resolver::collect_data(collection& facts)
    {
        data result;
        struct utsname name;
        if (uname(&name) == -1) {
            LOG_WARNING("uname failed: %1% (%2%): kernel facts are unavailable.", strerror(errno), errno);
            return result;
        }

        result.name = name.sysname;
        result.release = name.release;
        result.full_version = name.version;
        tie(result.major_version, result.minor_version) = version_parsing::parse_kernel_version(result.release);

        return result;
    }

}}}  // namespace facter::facts::solaris
