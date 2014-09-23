/**
 * @file
 * Declares the timezone fact resolver.
 */
#pragma once

#include "../resolver.hpp"
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

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * Implementations should set the timezone fact to the abbreviated form
         * of the system timezone.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts) override;

        /**
         * Gets the system timezone.
         * @return Returns the system timezone.
         */
        virtual std::string get_timezone() = 0;
    };

}}}  // namespace facter::facts::resolvers
