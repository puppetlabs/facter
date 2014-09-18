/**
 * @file
 * Declares the POSIX memory fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <cstdint>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving memory facts.
     */
    struct memory_resolver : resolver
    {
        /**
         * Constructs the memory_resolver.
         */
        memory_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);

        /**
         * Called to get the memory statistics.
         * @param facts The fact collection that is resolving facts.
         * @param mem_free The returned free memory amount.
         * @param mem_total The returned total memory amount.
         * @param swap_free The returned free swap amount.
         * @param swap_total The returned total swap amount.
         * @return Returns true if memory statistics is available or false if it is not.
         */
        virtual bool get_memory_statistics(
            collection& facts,
            uint64_t& mem_free,
            uint64_t& mem_total,
            uint64_t& swap_free,
            uint64_t& swap_total);

        /**
         * Represents the possible swap encryption status.
         */
        enum class encryption_status
        {
            /**
             * The swap encryption status is unknown.
             */
            unknown,
            /**
             * The swap is encrypted.
             */
            encrypted,
            /**
             * The swap is not encrypted.
             */
            not_encrypted
        };

        /**
         * Gets the status of swap encryption.
         * @return Returns the encryption_status for the swap.
         */
        virtual encryption_status get_swap_encryption_status();
    };

}}}  // namespace facter::facts::posix
