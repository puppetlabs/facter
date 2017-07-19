/**
 * @file
 * Declares the ZFS fact resolver.
 */
#pragma once

#include "../resolvers/zfs_resolver.hpp"

namespace facter { namespace facts { namespace freebsd {

    /**
     * Responsible for resolving ZFS facts.
     */
    struct zfs_resolver : resolvers::zfs_resolver
    {
     protected:
        /**
         * Gets the platform's ZFS command.
         * @return Returns the platform's ZFS command.
         */
        virtual std::string zfs_command();
    };

}}}  // namespace facter::facts::freebsd
