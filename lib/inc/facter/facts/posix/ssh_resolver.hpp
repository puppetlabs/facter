#ifndef FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving ssh facts.
     */
    struct ssh_resolver : fact_resolver
    {
        /**
         * Constructs the ssh_resolver.
         */
        ssh_resolver() :
            fact_resolver(
            "ssh",
            {
                fact::ssh_dsa_key,
                fact::ssh_rsa_key,
                fact::ssh_ecdsa_key,
                fact::ssh_ed25519_key,
                fact::sshfp_dsa,
                fact::sshfp_rsa,
                fact::sshfp_ecdsa,
                fact::sshfp_ed25519,
            })
        {
        }

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_SSH_RESOLVER_HPP_
