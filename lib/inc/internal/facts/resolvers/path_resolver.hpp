/**
 * @file
 * Declares the base PATH fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving path facts.
     */
    struct path_resolver : resolver
    {
        /**
         * Constructs the path_resolver.
         */
        path_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         * @param blocklist A list of facts that should not be collected.
         */
        virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;
    };

}}}  // namespace facter::facts::resolvers
