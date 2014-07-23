#include <facter/facts/linux/uptime_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <sys/sysinfo.h>

namespace facter { namespace facts { namespace linux {

    int uptime_resolver::uptime_in_seconds()
    {
        struct sysinfo info;
        if (sysinfo(&info) == 0) {
            return info.uptime;
        } else {
            return facter::facts::posix::uptime_resolver::uptime_in_seconds();
        }
    }

}}}  // namespace facter::facts::linux
