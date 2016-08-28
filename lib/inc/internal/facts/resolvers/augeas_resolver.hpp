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
         * @param blocklist A list of facts that should not be collected.
         */
        virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;

     protected:
        /**
         * Gets the augeas version.
         * @return The augeas version string.
         */
        virtual std::string get_version();
    };

}}}  // namespace facter::facts::resolvers
