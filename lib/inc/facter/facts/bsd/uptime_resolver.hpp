/**
 * @file
 * Declares the BSD uptime fact resolver.
 */
#pragma once

#include "../posix/uptime_resolver.hpp"

namespace facter { namespace facts { namespace bsd {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : posix::uptime_resolver
    {
     protected:
         /**
         * Gets the uptime in seconds.
         * @return Returns the system uptime in seconds.
         */
        virtual int uptime_in_seconds();
    };

}}}  // namespace facter::facts::bsd
