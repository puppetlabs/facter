#include <internal/facts/bsd/uptime_resolver.hpp>
#include <ctime>
#include <sys/sysctl.h>

using namespace std;

namespace facter { namespace facts { namespace bsd {

    int64_t uptime_resolver::get_uptime()
    {
        // this approach adapted from: http://stackoverflow.com/a/11676260/1004272
        timeval boottime;
        size_t len = sizeof(boottime);
        int mib[2] = { CTL_KERN, KERN_BOOTTIME };
        if (sysctl(mib, 2, &boottime, &len, NULL, 0) == 0) {
            time_t bsec = boottime.tv_sec;
            time_t now = time(NULL);
            return now - bsec;
        }
        return posix::uptime_resolver::get_uptime();
    }

}}}  // namespace facter::facts::bsd
