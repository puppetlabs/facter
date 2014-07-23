#include <facter/facts/bsd/uptime_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <time.h>
#include <sys/sysctl.h>

namespace facter { namespace facts { namespace bsd {

    int uptime_resolver::uptime_in_seconds()
    {
        // this approach adapted from: http://stackoverflow.com/a/11676260/1004272
        timeval boottime;
        size_t len = sizeof(boottime);
        int mib[2] = { CTL_KERN, KERN_BOOTTIME };
        if (sysctl(mib, 2, &boottime, &len, NULL, 0) == 0) {
            time_t bsec = boottime.tv_sec;
            time_t now = time(NULL);
            return now - bsec;
        } else {
            return facter::facts::posix::uptime_resolver::uptime_in_seconds();
        }
    }

}}}  // namespace facter::facts::bsd
