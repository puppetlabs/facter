/**
 * @file
 * Declares the base LDom (Logical Domain) fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <map>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving LDom facts.
     */
    struct ldom_resolver : resolver
    {
        /**
         * Constructs the ldom_resolver.
         */
        ldom_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

        protected:
            /**
             * Represents dynamic sub-keys consisting of LDom data.
             */
            struct ldom_info
            {
                /**
                 * Stores the top-level name of this category of LDom information.
                 */
                std::string key;

                /**
                 * Stores related LDom information.
                 */
                std::map<std::string, std::string> values;
            };

            /**
             * Represents the resolver's data.
             */
            struct data
            {
                /**
                 * Stores all gathered LDom data.
                 */
                std::vector<ldom_info> ldom;
            };

            /**
             * Collects the resolver data.
             * @param facts The fact collection that is resolving facts.
             * @return Returns the resolver data.
             */
            virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
