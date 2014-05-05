#ifndef FACTER_FACTS_BSD_UPTIME_RESOLVER_HPP_
#define FACTER_FACTS_BSD_UPTIME_RESOLVER_HPP_

#include "../posix/uptime_resolver.hpp"

namespace facter { namespace facts { namespace bsd {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : posix::uptime_resolver
    {
     protected:
        /**
         * Resolves the uptime in seconds on bsd.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_uptime_seconds(fact_map& facts);
    };

}}}  // namespace facter::facts::bsd

#endif  // FACTER_FACTS_BSD_UPTIME_RESOLVER_HPP_
