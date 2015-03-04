/**
* @file
* Declares the base EC2 fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving EC2 facts.
    */
    struct ec2_resolver : resolver
    {
        /**
         * Constructs the ec2_resolver.
         */
        ec2_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;
    };

}}}  // namespace facter::facts::resolvers
