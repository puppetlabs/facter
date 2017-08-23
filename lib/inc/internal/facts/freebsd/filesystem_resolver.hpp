/**
 * @file
 * Declares the FreeBSD file system fact resolver.
 */
#pragma once

#include "../bsd/filesystem_resolver.hpp"

namespace facter { namespace facts { namespace freebsd {

    /**
     * Responsible for resolving FreeBSD file system facts.
     */
    struct filesystem_resolver : bsd::filesystem_resolver
    {
     protected:
        /**
         * Collects the file system data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the file system data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::freebsd
