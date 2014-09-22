/**
 * @file
 * Declares the Zfs fact resolver.
 */
#pragma once

#include "../zfs/zfs_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving ZFS facts.
     */
    struct zfs_resolver : zfs::zfs_resolver
    {
     protected:
        /**
         * The ZFS command map
         * @return Returns command path
         */
        virtual std::string zfs_cmd();
    };

}}}  // namespace facter::facts::solaris
