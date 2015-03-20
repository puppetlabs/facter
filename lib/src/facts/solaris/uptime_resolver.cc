#include <internal/facts/solaris/uptime_resolver.hpp>
#include <internal/util/solaris/k_stat.hpp>
#include <sys/sysinfo.h>
#include <ctime>
#include <chrono>

using namespace std;
using namespace std::chrono;
using namespace facter::util::solaris;

namespace facter { namespace facts { namespace solaris {

    int64_t uptime_resolver::get_uptime()
    {
        try {
            k_stat ks;
            auto kv = ks[make_pair("unix", "system_misc")];
            auto time_at_boot_in_sec = kv[0].value<unsigned long>("boot_time");

            system_clock::time_point atboot{seconds(time_at_boot_in_sec)};
            system_clock::time_point now{system_clock::now()};
            seconds uptime{duration_cast<seconds>(now - atboot)};
            return uptime.count();
        } catch (kstat_exception&)
        {
            return posix::uptime_resolver::get_uptime();
        }
    }

}}}  // namespace facter::facts::solaris
