#include <facter/facts/resolvers/timezone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

namespace facter { namespace facts { namespace resolvers {

    timezone_resolver::timezone_resolver() :
        resolver(
            "timezone",
            {
                fact::timezone,
            })
    {
    }

    void timezone_resolver::resolve(collection& facts)
    {
        auto timezone = get_timezone();
        if (timezone.empty()) {
            return;
        }

        facts.add(fact::timezone, make_value<string_value>(move(timezone)));
    }

}}}  // facter::facts::resolvers
