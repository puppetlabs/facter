/**
 * @file
 * Declares the base user and group resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <boost/optional.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving the user and group facts.
     */
    struct identity_resolver : resolver
    {
        /**
         * Constructs the identity_resolver.
         */
        identity_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         * @param blocklist A list of facts that should not be collected.
         */
        virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;

     protected:
        /**
         * Represents user information data.
         */
        struct data
        {
            /**
             * Stores the id of the user.
             */
            boost::optional<int64_t> user_id;

            /**
             * Stores the name of the user.
             */
            std::string user_name;

            /**
             * Stores id of the user's primary group.
             */
            boost::optional<int64_t> group_id;

            /**
             * Stores the name of the user's primary group.
             */
            std::string group_name;

            /**
             * Stores whether facter is running as a privileged
             * process: With the effective UID of 0 on *NIX systems
             * or with elevated privileges on Windows (or with the
             * local Administrators group privileges on older versions
             * of windows not supporting privileges elevation).
             */
            boost::optional<bool> privileged;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
