/**
 * @file
 * Declares the POSIX file system fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_FILESYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_FILESYSTEM_RESOLVER_HPP_

#include "../resolver.hpp"
#include "../array_value.hpp"

struct statfs;

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving POSIX file system facts.
     */
    struct filesystem_resolver : resolver
    {
        /**
         * Constructs the filesystem_resolver.
         */
        filesystem_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
        /**
         * Called to resolve the mountpoints fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_mountpoints(collection& facts) = 0;
        /**
         * Called to resolve the filesystems fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_filesystems(collection& facts) = 0;
        /**
         * Called to resolve the partitions fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_partitions(collection& facts) = 0;
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_FILESYSTEM_RESOLVER_HPP_

