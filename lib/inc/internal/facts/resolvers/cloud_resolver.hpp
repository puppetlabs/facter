/**
* @file
* Declares the base cloud fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving the cloud fact.
    */
    struct cloud_resolver : resolver
    {
        /**
         * Constructs the cloud_resolver.
         */
        cloud_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

    protected:
        /**
         *  Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the cloud provider.
             */
            std::string provider;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        data collect_data(collection& facts);

        virtual std::string get_azure(collection& facts);
    };

}}}  // namespace facter::facts::resolvers
