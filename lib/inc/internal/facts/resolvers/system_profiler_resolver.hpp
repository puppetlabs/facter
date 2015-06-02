/**
 * @file
 * Declares the base system profiler fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving system profiler facts.
     */
    struct system_profiler_resolver : resolver
    {
        /**
         * Constructs the system_profiler_resolver.
         */
        system_profiler_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         *  Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the boot mode.
             */
            std::string boot_mode;
            /**
             * Stores the boot ROM version.
             */
            std::string boot_rom_version;
            /**
             * Stores the boot volume.
             */
            std::string boot_volume;
            /**
             * Stores the processor name.
             */
            std::string processor_name;
            /**
             * Stores the processor speed.
             */
            std::string processor_speed;
            /**
             * Stores the kernel version.
             */
            std::string kernel_version;
            /**
             * Stores the L2 cache per core.
             */
            std::string l2_cache_per_core;
            /**
             * Stores the L3 cache.
             */
            std::string l3_cache;
            /**
             * Stores the computer name.
             */
            std::string computer_name;
            /**
             * Stores the model identifier.
             */
            std::string model_identifier;
            /**
             * Stores the model name.
             */
            std::string model_name;
            /**
             * Stores the number of cores.
             */
            std::string cores;
            /**
             * Stores the system version.
             */
            std::string system_version;
            /**
             * Stores the number of processors.
             */
            std::string processors;
            /**
             * Stores the physical memory amount.
             */
            std::string memory;
            /**
             * Stores the hardware UUID.
             */
            std::string hardware_uuid;
            /**
             * Stores whether or not secure virtual memory is enabled.
             */
            std::string secure_virtual_memory;
            /**
             * Stores the system serial number.
             */
            std::string serial_number;
            /**
             * Stores the SMC version.
             */
            std::string smc_version;
            /**
             * Stores the system uptime.
             */
            std::string uptime;
            /**
             * Stores the user name.
             */
            std::string username;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
