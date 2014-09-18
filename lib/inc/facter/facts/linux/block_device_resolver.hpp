/**
 * @file
 * Declares the Linux block device fact resolver.
 */
#pragma once

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
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
    };

}}}  // namespace facter::facts::linux
