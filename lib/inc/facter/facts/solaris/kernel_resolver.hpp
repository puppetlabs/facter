/**
 * @file
 * Declares the Solaris kernel fact resolver.
 */
#pragma once

#include "../resolvers/kernel_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : resolvers::kernel_resolver
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
