/**
 * @file
 * Declares the SOLARIS kernel fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_KERNEL_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_KERNEL_RESOLVER_HPP_

#include "../posix/kernel_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : posix::kernel_resolver
    {
     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
    };

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_KERNEL_RESOLVER_HPP_

