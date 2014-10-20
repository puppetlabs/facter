/**
 * @file
 * Declares the Zpool fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>
#include <vector>

namespace facter { namespace facts { namespace zfs {

    /**
     * Responsible for resolving Zpool facts.
     */
    struct zpool_resolver : resolver
    {
        /**
         * Constructs the zpool_resolver.
         */
        zpool_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * The zfs command map
         * @return Returns command path
         */
        virtual std::string zpool_cmd() = 0;
    };

}}}  // namespace facter::facts::zfs
