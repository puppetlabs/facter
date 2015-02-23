#include <facter/facts/solaris/kernel_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/utsname.h>

using namespace std;

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
        result.version = name.version;
        return result;
    }

}}}  // namespace facter::facts::solaris
