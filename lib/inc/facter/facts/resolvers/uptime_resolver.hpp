/**
 * @file
 * Declares the base uptime fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <cstdint>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : resolver
    {
        /**
         * Constructs the uptime_resolver.
         */
        uptime_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Gets the system uptime in seconds.
         * @return Returns the system uptime in seconds.
         */
        virtual int64_t get_uptime() = 0;
    };

}}}  // namespace facter::facts::resolvers
