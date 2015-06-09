/**
* @file
* Declares the base augeas fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving augeas fact, when an augeas runtime is available.
    */
    struct augeas_resolver : resolver
    {
        /**
         * Constructs the augeas_resolver.
         */
        augeas_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Gets the augeas version.
         * @return The augeas version string.
         */
        virtual std::string get_version();
    };

}}}  // namespace facter::facts::resolvers
