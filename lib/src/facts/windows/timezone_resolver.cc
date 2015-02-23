#include <facter/facts/windows/timezone_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <ctime>

using namespace std;

namespace facter { namespace facts { namespace windows {

    string timezone_resolver::get_timezone()
    {
        time_t since_epoch = time(NULL);
        struct tm localtime;
        // allocate a larger buffer, because Windows by default returns an expanded timezone string
        char buffer[80];

        // localtime_s returns 0 on success
        if (localtime_s(&localtime, &since_epoch)) {
            LOG_WARNING("localtime failed: timezone is unavailable: %1% (%2%)", strerror(errno), errno);
            return {};
        }
        if (strftime(buffer, sizeof(buffer), "%Z", &localtime) == 0) {
            LOG_WARNING("strftime failed: timezone is unavailable: %1% (%2%)", strerror(errno), errno);
            return {};
        }
        return buffer;
    }

}}}  // facter::facts::windows
