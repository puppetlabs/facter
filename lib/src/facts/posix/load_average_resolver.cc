#include <internal/facts/posix/load_average_resolver.hpp>
#include <stdlib.h>
#include <array>
#include <boost/optional.hpp>
#include <leatherman/logging/logging.hpp>

#ifdef __sun
#include <sys/loadavg.h>
#endif

using namespace std;

namespace facter { namespace facts { namespace posix {

    boost::optional<tuple<double, double, double> > load_average_resolver::get_load_averages()
    {
        array<double, 3> averages;
        if (getloadavg(averages.data(), averages.size()) == -1) {
            LOG_DEBUG("failed to retrieve load averages: %1% (%2%).", strerror(errno), errno);
            return nullptr;
        }
        return make_tuple(averages[0], averages[1], averages[2]);
    }
}}}  // namespace facter::facts::posix
