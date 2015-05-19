#include <internal/facts/posix/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/logging/logging.hpp>
#include <sys/utsname.h>

using namespace std;

namespace facter { namespace facts { namespace posix {

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

#ifdef _AIX  // On AIX, we actually want the uname 'version' field - everywhere else we parse release
        result.version = name.version;
#else
        result.version = result.release.substr(0, result.release.find('-'));
#endif
        return result;
    }

}}}  // namespace facter::facts::posix
