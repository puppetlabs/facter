/**
 * @file
 * Declares the Zpool fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>
#include <vector>

namespace facter { namespace facts { namespace zfs {

    struct zpool {
        /**
         * The name of this zpool
         */
        std::string name;

        /**
         * The size of this zpool
         */
        std::string size;

        /**
         * The size available in this zpool
         */
        std::string available;

        /**
         * The disks within the poool
         */
        std::vector<std::string> disks;
    };
    /**
     * Responsible for resolving Zpool facts.
     */
    struct zpool_resolver : resolver
    {
        /**
         * Constructs the zpool_resolver.
         */
        zpool_resolver();

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
        virtual std::string zpool_cmd() = 0;

        /**
         * The zpools configured
         * @return Returns a vector of configured zpools
         */

        virtual std::vector<zpool> zpool_list();
    };

}}}  // namespace facter::facts::zfs
