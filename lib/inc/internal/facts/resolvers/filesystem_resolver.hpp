/**
 * @file
 * Declares the base file system fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <vector>
#include <set>
#include <cstdint>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving file system facts.
     */
    struct filesystem_resolver : resolver
    {
        /**
         * Constructs the filesystem_resolver.
         */
        filesystem_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

        bool is_blockable() const override;
     protected:
        /**
         * Represents data about a mountpoint.
         */
        struct mountpoint
        {
            /**
             * Constructs a mountpoint.
             */
            mountpoint() :
                size(0),
                available(0),
                free(0)
            {
            }

            /**
             * Stores the mountpoint name (the mount location).
             */
            std::string name;

            /**
             * Stores the mounted device.
             */
            std::string device;

            /**
             * Stores the filesystem of the mountpoint.
             */
            std::string filesystem;

            /**
             * Stores the total size of the mountpoint.
             */
            uint64_t size;

            /**
             * Stores the available size of the mountpoint.
             */
            uint64_t available;

            /**
             * Stores the free size of the mountpoint.
             */
            uint64_t free;

            /**
             * Stores the mountpoint options.
             */
            std::vector<std::string> options;
        };

        /**
         * Represents data about a partition.
         */
        struct partition
        {
            /**
             * Constructs a partition.
             */
            partition() :
                size(0)
            {
            }

            /**
             * Stores the name of the partition.
             */
            std::string name;

            /**
             * Stores the file system of the partition.
             */
            std::string filesystem;

            /**
             * Stores the size of the partition.
             */
            uint64_t size;

            /**
             * Stores the UUID of the file system.
             */
            std::string uuid;

            /**
             * Stores the UUID of the GPT partition.
             */
            std::string partition_uuid;

            /**
             * Stores the label of the file system.
             */
            std::string label;

            /**
             * Stores the label of the GPT partition.
             */
            std::string partition_label;

            /**
             * Stores the partition mountpoint.
             */
            std::string mount;

            /**
             * Stores the backing file for partitions backed by a file.
             */
            std::string backing_file;
        };

        /**
         *  Represents file system data.
         */
        struct data
        {
            /**
             * Stores the mountpoint data.
             */
            std::vector<mountpoint> mountpoints;

            /**
             * Stores the filesystems.
             */
            std::set<std::string> filesystems;

            /**
             * Stores the partitions data.
             */
            std::vector<partition> partitions;
        };

        /**
         * Collects the file system data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the file system data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
