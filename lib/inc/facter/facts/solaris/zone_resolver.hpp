/**
 * @file
 * Declares the Solaris zone fact resolver.
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving memory facts.
     */
    struct zone_resolver : resolver
    {
        /**
         * Constructs the zone_resolver.
         */
        zone_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
    };

}}}  // namespace facter::facts::solaris
