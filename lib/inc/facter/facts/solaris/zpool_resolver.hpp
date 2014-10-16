/**
 * @file
 * Declares the Zpool fact resolver.
 */
#pragma once

#include "../zfs/zpool_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving zpool facts.
     */
    struct zpool_resolver : zfs::zpool_resolver
    {
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
        virtual std::string zpool_cmd();
    };

}}}  // namespace facter::facts::solaris
