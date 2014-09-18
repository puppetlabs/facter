/**
 * @file
 * Declares the timezone fact resolver
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

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
        virtual void resolve_facts(collection& facts);
    };

}}}  // namespace facter::facts::posix
