/**
* @file
* Declares the base fips fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {


    /**
     * Responsible for resolving fips facts.
     */
    struct fips_resolver : resolver
    {
        fips_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         *  Represents fips data.
         */
        struct data
        {
            /**
             * Stores the is_fips_mode_enabled data.
             */
            bool is_fips_mode_enabled;
        };

        /**
         *
         * Collects fips data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the fips data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
