#include <internal/facts/linux/uptime_resolver.hpp>
#include <sys/sysinfo.h>

namespace facter { namespace facts { namespace linux {

    int64_t uptime_resolver::get_uptime(collection& facts)
    {
        struct sysinfo info;
        if (sysinfo(&info) == 0) {
            return info.uptime;
        }
        return posix::uptime_resolver::get_uptime(facts);
    }

}}}  // namespace facter::facts::linux
