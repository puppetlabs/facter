/**
 * @file
 * Declares the POSIX SSH fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_

#include "../fact_resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving ssh facts.
     */
    struct ssh_resolver : fact_resolver
    {
        /**
         * Constructs the ssh_resolver.
         */
        ssh_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_
