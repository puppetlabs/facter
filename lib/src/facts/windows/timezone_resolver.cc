#include <internal/facts/windows/timezone_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/nowide/convert.hpp>
#include <ctime>

using namespace std;

namespace facter { namespace facts { namespace windows {

    string timezone_resolver::get_timezone()
    {
        time_t since_epoch = time(NULL);
        tm localtime;

        if (localtime_s(&localtime, &since_epoch)) {
            LOG_WARNING("localtime failed: timezone is unavailable: {1} ({2})", strerror(errno), errno);
            return {};
        }

        wchar_t buffer[256] = {};
        if (wcsftime(buffer, (sizeof(buffer) / sizeof(wchar_t)) - 1, L"%Z", &localtime) == 0) {
            LOG_WARNING("wcsftime failed: timezone is unavailable: {1} ({2})", strerror(errno), errno);
            return {};
        }
        return boost::nowide::narrow(buffer);
    }

}}}  // facter::facts::windows
