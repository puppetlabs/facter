#include <internal/facts/windows/uptime_resolver.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/locale/locale.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

namespace facter { namespace facts { namespace windows {

    using namespace std;
    using namespace leatherman::util;
    using namespace leatherman::windows;

    uptime_resolver::uptime_resolver() :
        resolvers::uptime_resolver()
    {
    }

    int64_t uptime_resolver::get_uptime()
    {
        uint64_t tickCount = GetTickCount64();
        return (int64_t)(tickCount / 1000);  // seconds
    }

}}}  // namespace facter::facts::windows
