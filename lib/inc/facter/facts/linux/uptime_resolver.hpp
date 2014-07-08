/**
 * @file
 * Declares the Linux uptime fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_UPTIME_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_UPTIME_RESOLVER_HPP_

#include "../posix/uptime_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : posix::uptime_resolver
    {
     protected:
        /**
         * Resolves the uptime in seconds on linux.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_uptime_seconds(collection& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_UPTIME_RESOLVER_HPP_
