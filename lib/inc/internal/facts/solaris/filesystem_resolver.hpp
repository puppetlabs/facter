/**
 * @file
 * Declares the Solaris file system fact resolver.
 */
#pragma once

#include "../resolvers/filesystem_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving Solaris file system facts.
     */
    struct filesystem_resolver : resolvers::filesystem_resolver
    {
     protected:
        /**
         * Collects the file system data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the file system data.
         */
        virtual data collect_data(collection& facts) override;

     private:
        void collect_mountpoint_data(data& result);
        void collect_filesystem_data(data& result);
    };

}}}  // namespace facter::facts::solaris
