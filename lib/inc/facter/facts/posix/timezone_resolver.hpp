/**
 * @file
 * Declares the timezone fact resolver
 */
#ifndef FACTER_FACTS_POSIX_TIMEZONE_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_TIMEZONE_RESOLVER_HPP_

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

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

#endif  // FACTER_FACTS_POSIX_TIMEZONE_RESOLVER_HPP_
