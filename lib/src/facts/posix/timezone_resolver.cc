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
        struct tm *result;
        result = localtime_r(&since_epoch, &localtime);

        if (result) {
            int is_dst = daylight && localtime.tm_isdst;
            facts.add(fact::timezone, make_value<string_value>(tzname[is_dst]));
        } else {
            LOG_WARNING("localtime_r failed: %1% fact is unavailable", fact::timezone);
        }
    }
}}}  // facter::facts::posix
