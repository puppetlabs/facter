/**
* @file
* Declares the base Google Compute Engine (GCE) fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving GCE facts.
    */
    struct gce_resolver : resolver
    {
        /**
         * Constructs the gce_resolver.
         */
        gce_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;
    };

}}}  // namespace facter::facts::resolvers
