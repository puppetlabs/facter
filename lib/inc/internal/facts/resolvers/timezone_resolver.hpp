/**
 * @file
 * Declares the timezone fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving time zone facts.
     */
    struct timezone_resolver : resolver
    {
        /**
         * Constructs the timezone resolver.
         */
        timezone_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         * @param blocklist A list of facts that should not be collected.
         */
        virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;

     protected:
        /**
         * Gets the system timezone.
         * @return Returns the system timezone.
         */
        virtual std::string get_timezone() = 0;
    };

}}}  // namespace facter::facts::resolvers
