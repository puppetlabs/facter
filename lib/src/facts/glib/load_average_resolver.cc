#include <internal/facts/glib/load_average_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <cstdlib>

#ifdef __sun
#include <sys/loadavg.h>
#endif

using namespace std;

namespace facter { namespace facts { namespace glib {

    boost::optional<tuple<double, double, double> > load_average_resolver::get_load_averages()
    {
        array<double, 3> averages;
        if (getloadavg(averages.data(), averages.size()) == -1) {
            LOG_DEBUG("failed to retrieve load averages: {1} ({2}).", strerror(errno), errno);
            return boost::none;
        }
        return make_tuple(averages[0], averages[1], averages[2]);
    }
}}}  // namespace facter::facts::glib
