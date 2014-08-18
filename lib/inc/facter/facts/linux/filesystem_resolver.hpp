/**
 * @file
 * Declares the Linux file system fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_FILESYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_FILESYSTEM_RESOLVER_HPP_

#include "../posix/filesystem_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving Linux file system facts.
     */
    struct filesystem_resolver : posix::filesystem_resolver
    {
     protected:
        /**
         * Called to resolve the mountpoints fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_mountpoints(collection& facts);
        /**
         * Called to resolve the filesystems fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_filesystems(collection& facts);
        /**
         * Called to resolve the partitions fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_partitions(collection& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_FILESYSTEM_RESOLVER_HPP_

