/**
 * @file
 * Declares the base processor fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>
#include <vector>
#include <cstdint>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : resolver
    {
        /**
         * Constructs the processor_resolver.
         */
        processor_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents processor resolver data.
         */
        struct data
        {
            /**
             * Constructs the processor resolver data.
             */
            data():
                physical_count(0),
                logical_count(0),
                speed(0)
            {
            }

            /**
             * Stores the physical count of processors.
             */
            int physical_count;

            /**
             * Stores the logical count of processors.
             */
            int logical_count;

            /**
             * Stores the processor model strings.
             */
            std::vector<std::string> models;

            /**
             * Stores the processor speed, in Hz.
             */
            int64_t speed;

            /**
             * Stores the processor instruction set architecture.
             */
            std::string isa;

            /**
             * Stores the processor hardware model.
             */
            std::string hardware;

            /**
             * Stores the system architecture.
             */
            std::string architecture;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
