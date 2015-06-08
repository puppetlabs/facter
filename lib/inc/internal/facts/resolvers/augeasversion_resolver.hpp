/**
* @file
* Declares the base augeasversion fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving augeasversion fact, when an augeas runtime is available.
    */
    struct augeasversion_resolver : resolver
    {
        /**
         * Constructs the augeasversion_resolver.
         */
        augeasversion_resolver();

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
