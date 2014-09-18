/**
 * @file
 * Declares the BSD file system fact resolver.
 */
#pragma once

#include "../posix/filesystem_resolver.hpp"
#include "../array_value.hpp"

struct statfs;

namespace facter { namespace facts { namespace bsd {

    /**
     * Responsible for resolving BSD file system facts.
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

     private:
         std::unique_ptr<facter::facts::array_value> make_options_value(struct statfs const& fs);
    };

}}}  // namespace facter::facts::bsd
