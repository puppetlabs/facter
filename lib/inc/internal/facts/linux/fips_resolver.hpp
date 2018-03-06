/**
 * @file
 * Declares the Linux fips fact resolver.
 */
#pragma once

#include "../resolvers/fips_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving fips-related facts.
     */
    struct fips_resolver : resolvers::fips_resolver
    {
     protected:
        /**
         * The check consists of the following.
         *   (1) Examining the contents of /proc/sys/crypto/fips_enabled. If it is 1
         *   then fips mode is enabled.
         */ 

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::linux
