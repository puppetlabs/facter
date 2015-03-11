/**
 * @file
 * Declares the ZFS storage pool (zpool) fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <vector>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving ZFS storage pool (zpool) facts.
     */
    struct zpool_resolver : resolver
    {
        /**
         * Constructs the zpool_resolver.
         */
        zpool_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Gets the platform's zpool command.
         * @return Returns the platform's zpool command.
         */
        virtual std::string zpool_command() = 0;

        /**
         *  Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the zpool version.
             */
            std::string version;
            /**
             * Stores the zpool feature numbers.
             */
            std::vector<std::string> features;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts);
    };

}}}  // namespace facter::facts::resolvers
