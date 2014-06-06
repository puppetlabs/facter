/**
 * @file
 * Declares the software (OSX) version fact resolver.
 */
#ifndef FACTER_FACTS_OSX_SOFTWARE_VERSION_RESOLVER_HPP_
#define FACTER_FACTS_OSX_SOFTWARE_VERSION_RESOLVER_HPP_

#include "../fact_resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving software (OSX) version facts.
     */
    struct software_version_resolver : fact_resolver
    {
        /**
         * Constructs the software_version_resolver.
         */
        software_version_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);
    };

}}}  // namespace facter::facts::osx

#endif  // FACTER_FACTS_OSX_SOFTWARE_VERSION_RESOLVER_HPP_
