/**
 * @file
 * Declares the base PATH fact resolver.
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving path facts.
     */
    struct path_resolver : resolver
    {
        /**
         * Constructs the path_resolver.
         */
        path_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;
    };

}}}  // namespace facter::facts::resolvers
