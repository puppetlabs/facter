#include <facter/facts/posix/timezone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <time.h>

LOG_DECLARE_NAMESPACE("facts.posix.timezone");

namespace facter { namespace facts { namespace posix {

    timezone_resolver::timezone_resolver() :
        resolver(
            "timezone",
            {
                fact::timezone,
            })
    {
    }

    void timezone_resolver::resolve_facts(collection& facts)
    {
        time_t since_epoch = time(NULL);
        struct tm localtime;
        char buffer[16];

        if (!::localtime_r(&since_epoch, &localtime)) {
            LOG_WARNING("localtime_r failed: %1% fact is unavailable", fact::timezone);
        } else if (::strftime(buffer, sizeof(buffer), "%Z", &localtime) == 0) {
            LOG_WARNING("strftime failed: %1% fact is unavailable", fact::timezone);
        } else {
            facts.add(fact::timezone, make_value<string_value>(buffer));
        }
    }
}}}  // facter::facts::posix
