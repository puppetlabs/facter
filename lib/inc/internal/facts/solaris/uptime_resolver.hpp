/**
 * @file
 * Declares the solaris uptime fact resolver.
 */
#pragma once

#include "../posix/uptime_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : posix::uptime_resolver
    {
     protected:
        /**
         * Gets the system uptime in seconds.
         * @param facts The fact collection.
         * @return Returns the system uptime in seconds.
         */
        virtual int64_t get_uptime(collection& facts) override;
    };

}}}  // namespace facter::facts::solaris
