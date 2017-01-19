/**
 * @file
 * Declares the AIX file system fact resolver.
 */
#pragma once

#include "../resolvers/filesystem_resolver.hpp"
#include <map>

namespace facter { namespace facts { namespace aix {

    /**
     * Responsible for resolving AIX file system facts.
     */
    struct filesystem_resolver : resolvers::filesystem_resolver
    {
     protected:
        /**
         * Collects the DMI data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the DMI data.
         */
        virtual data collect_data(collection& facts) override;

     private:
        void collect_filesystem_data(data& result);
        void collect_mountpoint_data(data& result);
        void collect_partition_data(data& result);

    private:
        // AIX tracks filesystems as numeric IDs. We need to load up
        // the human-readable names from /etc before we can print them
        // out nicely.
        std::map<int, std::string> _filesystems;

        // This stores which partitions are mounted where, so we don't have
        // to scan the array of mountpoints when populating partitions.
        std::map<std::string, std::string> _mounts;
    };

}}}  // namespace facter::facts::aix
