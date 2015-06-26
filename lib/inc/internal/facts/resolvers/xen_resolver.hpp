/**
 * @file
 * Declares the Xen fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <vector>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving Xen facts.
     */
    struct xen_resolver : resolver
    {
        /**
         * Constructs the xen_resolver.
         */
        xen_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Gets the Xen management command.
         * @return Returns the Xen management command.
         */
        virtual std::string xen_command() = 0;

        /**
         *  Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the Xen domains.
             */
            std::vector<std::string> domains;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts);
    };

}}}  // namespace facter::facts::resolvers
