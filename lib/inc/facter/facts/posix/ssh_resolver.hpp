/**
 * @file
 * Declares the POSIX SSH fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving ssh facts.
     */
    struct ssh_resolver : resolver
    {
        /**
         * Constructs the ssh_resolver.
         */
        ssh_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_
