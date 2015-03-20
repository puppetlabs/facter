/**
 * @file
 * Declares the base memory fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <cstdint>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving memory facts.
     */
    struct memory_resolver : resolver
    {
        /**
         * Constructs the memory_resolver.
         */
        memory_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
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
         * Represents data about system memory.
         */
        struct data
        {
            /**
             * Constructs the data.
             */
            data() :
                mem_free(0),
                mem_total(0),
                swap_free(0),
                swap_total(0),
                swap_encryption(encryption_status::unknown)
            {
            }

            /**
             * Stores the free memory, in bytes.
             */
            uint64_t mem_free;

            /**
             * Stores the total memory, in bytes.
             */
            uint64_t mem_total;

            /**
             * Stores the free swap, in bytes.
             */
            uint64_t swap_free;

            /**
             * Stores the total swap, in bytes.
             */
            uint64_t swap_total;

            /**
             * Stores the swap encryption status.
             */
            encryption_status swap_encryption;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
