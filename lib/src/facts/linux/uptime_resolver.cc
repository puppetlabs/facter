#include <facter/facts/linux/uptime_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/integer_value.hpp>
#include <sys/sysinfo.h>

namespace facter { namespace facts { namespace linux {

    void uptime_resolver::resolve_uptime_seconds(fact_map& facts)
    {
        struct sysinfo info;
        if (sysinfo(&info) == 0) {
            facts.add(fact::uptime_seconds, make_value<integer_value>(info.uptime));
        } else {
            facter::facts::posix::uptime_resolver::resolve_uptime_seconds(facts);
        }
    }

}}}  // namespace facter::facts::linux
