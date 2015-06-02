/**
 * @file
 * Declares the Linux file system fact resolver.
 */
#pragma once

#include "../resolvers/filesystem_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving Linux file system facts.
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
        void collect_mountpoint_data(data& result);
        void collect_filesystem_data(data& result);
        void collect_partition_data(data& result);
    };

}}}  // namespace facter::facts::linux
