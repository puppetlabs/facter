#include <facter/facts/posix/timezone_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <time.h>

using namespace std;

namespace facter { namespace facts { namespace posix {

    string timezone_resolver::get_timezone()
    {
        time_t since_epoch = time(NULL);
        tm localtime;
        char buffer[16];

        if (!::localtime_r(&since_epoch, &localtime)) {
            LOG_WARNING("localtime_r failed: timezone is unavailable.");
            return {};
        }
        if (::strftime(buffer, sizeof(buffer), "%Z", &localtime) == 0) {
            LOG_WARNING("strftime failed: timezone is unavailable.");
            return {};
        }
        return buffer;
    }

}}}  // facter::facts::posix
