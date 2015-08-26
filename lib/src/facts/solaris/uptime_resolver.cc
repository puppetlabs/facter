#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>
#include <internal/facts/solaris/uptime_resolver.hpp>
#include <internal/util/solaris/k_stat.hpp>
#include <sys/sysinfo.h>
#include <ctime>
#include <chrono>

using namespace std;
using namespace std::chrono;
using namespace facter::util::solaris;

namespace facter { namespace facts { namespace solaris {

    int64_t uptime_resolver::get_uptime(collection& facts)
    {
        // If the current zone is 'global', we can use kstat. If not, kstat will return the uptime of the machine, not
        // the uptime of the current zone. Facter's historical behavior has been to return uptime matching 'uptime',
        // which means the uptime of the current zone. So if not 'global', use POSIX behavior i.e. call 'uptime'.
        auto current_zone = facts.get<string_value>(fact::zonename);
        if (current_zone && current_zone->value() == "global") {
            try {
                k_stat ks;
                auto kv = ks[make_pair("unix", "system_misc")];
                auto time_at_boot_in_sec = kv[0].value<unsigned long>("boot_time");

                system_clock::time_point atboot{seconds(time_at_boot_in_sec)};
                system_clock::time_point now{system_clock::now()};
                seconds uptime{duration_cast<seconds>(now - atboot)};
                return uptime.count();
            } catch (kstat_exception&) {
                // Ignore kstat exceptions and defer to POSIX uptime.
            }
        }

        return posix::uptime_resolver::get_uptime(facts);
    }

}}}  // namespace facter::facts::solaris
