/**
 * @file
 * Declares the ldom fact resolver.
 */
#pragma once

#include "../resolvers/ldom_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving ldom facts.
     */
    struct ldom_resolver : resolvers::ldom_resolver
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
