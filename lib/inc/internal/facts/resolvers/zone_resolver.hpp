/**
 * @file
 * Declares the base Solaris zone fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <vector>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving Solaris zone facts.
     */
    struct zone_resolver : resolver
    {
        /**
         * Constructs the zone_resolver.
         */
        zone_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents a Solaris zone.
         */
        struct zone
        {
            /**
             * Stores the zone id.
             */
            std::string id;

            /**
             * Stores the zone name.
             */
            std::string name;

            /**
             * Stores the zone status.
             */
            std::string status;

            /**
             * Stores the zone path.
             */
            std::string path;

            /**
             * Stores the zone unique identifier.
             */
            std::string uuid;

            /**
             * Stores the zone brand.
             */
            std::string brand;

            /**
             * Stores the zone IP type.
             */
            std::string ip_type;
        };

        /**
         * Represents the resolver data.
         */
        struct data
        {
            /**
             * Stores the Solaris zones.
             */
            std::vector<zone> zones;

            /**
             * Stores the current zone name.
             */
            std::string current_zone_name;
        };

        /**
        * Collects the resolver data.
        * @param facts The fact collection that is resolving facts.
        * @return Returns the resolver data.
        */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
