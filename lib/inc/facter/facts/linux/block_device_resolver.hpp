/**
 * @file
 * Declares the Linux block device fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_BLOCK_DEVICE_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_BLOCK_DEVICE_RESOLVER_HPP_

#include "../resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving block device facts.
     */
    struct block_device_resolver : resolver
    {
        /**
         * Constructs the block_device_resolver.
         */
        block_device_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_BLOCK_DEVICE_RESOLVER_HPP_
