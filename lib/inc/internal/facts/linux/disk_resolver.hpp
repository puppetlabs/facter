/**
 * @file
 * Declares the Linux disk fact resolver.
 */
#pragma once

#include "../resolvers/disk_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving disk facts.
     */
    struct disk_resolver : resolvers::disk_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::linux
