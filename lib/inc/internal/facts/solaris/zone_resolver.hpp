/**
* @file
* Declares the Solaris zone fact resolver.
*/
#pragma once

#include "../resolvers/zone_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving Solaris zone facts.
     */
    struct zone_resolver : resolvers::zone_resolver
    {
     protected:
        /**
        * Collects the resolver data.
        * @param facts The fact collection that is resolving facts.
        * @return Returns the resolver data.
        */
        virtual data collect_data(collection& facts);
    };

}}}  // namespace facter::facts::solaris
