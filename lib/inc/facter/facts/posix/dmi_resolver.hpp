/**
 * @file
 * Declares the POSIX Desktop Management Information (DMI) fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_DMI_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_DMI_RESOLVER_HPP_

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving DMI facts.
     */
    struct dmi_resolver : resolver
    {
        /**
         * Constructs the dmi_resolver.
         */
        dmi_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts) = 0;
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_DMI_RESOLVER_HPP_

