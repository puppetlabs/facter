/**
 * @file
 * Declares the Zfs fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>
#include <map>

namespace facter { namespace facts { namespace zfs {

    /**
     * Responsible for resolving ZFS facts.
     */
    struct zfs_resolver : resolver
    {
        /**
         * Constructs the zfs_resolver.
         */
        zfs_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);

        /**
         * The zfs command map
         * @return Returns command path
         */
        virtual std::string zfs_cmd() = 0;
    };

}}}  // namespace facter::facts::zfs
