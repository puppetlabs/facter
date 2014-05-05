#include <time.h>
#include <sys/sysctl.h>
#include <facter/facts/bsd/uptime_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/integer_value.hpp>

namespace facter { namespace facts { namespace bsd {

    void uptime_resolver::resolve_uptime_seconds(fact_map& facts)
    {
        // this approach adapted from: http://stackoverflow.com/a/11676260/1004272
        timeval boottime;
        size_t len = sizeof(boottime);
        int mib[2] = { CTL_KERN, KERN_BOOTTIME };
        if (sysctl(mib, 2, &boottime, &len, NULL, 0) == 0) {
            time_t bsec = boottime.tv_sec;
            time_t now = time(NULL);
            int uptime = now - bsec;
            facts.add(fact::uptime_seconds, make_value<integer_value>(uptime));
        } else {
            facter::facts::posix::uptime_resolver::resolve_uptime_seconds(facts);
        }
    }

}}}  // namespace facter::facts::bsd
