/**
 * @file
 * Declares the Solaris memory fact resolver.
 */
#pragma once

#include "../resolvers/memory_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving memory facts.
     */
    struct memory_resolver : resolvers::memory_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::solaris
