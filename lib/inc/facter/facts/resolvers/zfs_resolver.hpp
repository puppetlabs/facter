/**
 * @file
 * Declares the Solaris ZFS fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>
#include <vector>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving ZFS facts.
     */
    struct zfs_resolver : resolver
    {
        /**
         * Constructs the zfs_resolver.
         */
        zfs_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Gets the platform's ZFS command.
         * @return Returns the platform's ZFS command.
         */
        virtual std::string zfs_command() = 0;

        /**
         *  Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the ZFS version.
             */
            std::string version;
            /**
             * Stores the ZFS feature numbers.
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
