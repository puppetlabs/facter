#include <internal/facts/aix/load_average_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>

#include <sys/inttypes.h>
#include <sys/kinfo.h>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;

/**
 * This system call lets us query the kernel directly for system
 * information. We use it to get our current load averages.
 *
 * @param info the info we're retrieving from the kernel.
 * @param buf the buffer that we'll store the information in
 * @param buf_size a pointer to the variable containing the size of the buffer in bytes
 * @param arg no idea what this param. represents. we will usually set this to 0.
 * @return 0 if we successfully retrieve the information, else a negative value
 */
extern "C" int getkerninfo(int info, char* buf, int* buf_size, int32long64_t arg);

// Converts the given integer average into a load average.
static double to_load_avg(double average) {
  // 65536 is the load average scale on AIX machines.
  return average / 65536;
}

namespace facter { namespace facts { namespace aix {

    boost::optional<tuple<double, double, double> > load_average_resolver::get_load_averages()
    {
        // This approach was adapted from screen-4.6.2's loadav.c file. See
        // https://www.mail-archive.com/opensuse-commit@opensuse.org/msg122486.html
        array<long long, 3> averages;
        int buf_size = averages.size() * sizeof(long long);
        int rc = getkerninfo(KINFO_GET_AVENRUN, reinterpret_cast<char*>(averages.data()), &buf_size, 0);
        if (rc < 0) {
            LOG_DEBUG(_("failed to retrieve the load averages"));
            return boost::none;
        }

        return make_tuple(
            to_load_avg(averages[0]),
            to_load_avg(averages[1]),
            to_load_avg(averages[2]));
    }
}}}  // namespace facter::facts::aix
