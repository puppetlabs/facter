#include <facter/facts/solaris/uptime_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <kstat.h>
#include <sys/sysinfo.h>
#include <ctime>
#include <chrono>

LOG_DECLARE_NAMESPACE("facts.solaris.uptime");

using namespace std::chrono;

namespace facter { namespace facts { namespace solaris {

    int uptime_resolver::uptime_in_seconds()
    {
        kstat_ctl_t *kc;

        if ((kc = kstat_open()) == nullptr) {
            LOG_DEBUG("kstat_open failed: %1% (%2%): using /bin/uptime.", strerror(errno), errno);
            return facter::facts::posix::uptime_resolver::uptime_in_seconds();
        }

        kstat_t *kp;
        if ((kp = kstat_lookup(kc, const_cast<char*>("unix"), 0, const_cast<char *>("system_misc"))) == nullptr) {
            kstat_close(kc);
            LOG_DEBUG("kstat_lookup failed: %1% (%2%): using /bin/uptime.", strerror(errno), errno);
            return facter::facts::posix::uptime_resolver::uptime_in_seconds();
        }

        if (kstat_read(kc, kp, 0) == -1) {
            kstat_close(kc);
            LOG_DEBUG("kstat_lookup failed: %1% (%2%): using /bin/uptime.", strerror(errno), errno);
            return facter::facts::posix::uptime_resolver::uptime_in_seconds();
        }

        kstat_named_t *knp;
        if ((knp = reinterpret_cast<kstat_named_t*>(kstat_data_lookup(kp, const_cast<char *>("boot_time")))) == nullptr) {
            kstat_close(kc);
            LOG_DEBUG("kstat_lookup failed: %1% (%2%): using /bin/uptime.", strerror(errno), errno);
            return facter::facts::posix::uptime_resolver::uptime_in_seconds();
        }
        kstat_close(kc);

        auto time_at_boot_in_sec = knp->value.ul;
        system_clock::time_point atboot{seconds(time_at_boot_in_sec)};
        system_clock::time_point now{system_clock::now()};
        seconds uptime{duration_cast<seconds>(now - atboot)};
        return uptime.count();
    }

}}}  // namespace facter::facts::solaris
