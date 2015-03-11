/**
 * @file
 * Declares the base disk resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <cstdint>
#include <vector>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving disk facts.
     */
    struct disk_resolver : resolver
    {
        /**
         * Constructs the disk_resolver.
         */
        disk_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents a disk.
         */
        struct disk
        {
            /**
             * Stores the name of the disk.
             */
            std::string name;

            /**
             * Stores the vendor of the disk.
             */
            std::string vendor;

            /**
             * Stores the model of the disk.
             */
            std::string model;

            /**
             * Stores the product of the disk.
             */
            std::string product;

            /**
             * Stores the size of the disk.
             */
            uint64_t size;
        };

        /**
         *  Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the disks.
             */
            std::vector<disk> disks;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
