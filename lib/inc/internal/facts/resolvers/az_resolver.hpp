/**
* @file
* Declares the base AZ fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving AZ facts.
    */
    struct az_resolver : resolver
    {
        /**
         * Constructs the az_resolver.
         */
        az_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

        bool is_blockable() const override;
    };

}}}  // namespace facter::facts::resolvers
