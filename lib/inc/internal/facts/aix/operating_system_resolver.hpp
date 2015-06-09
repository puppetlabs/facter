/**
 * @file
 * Declares the aix operating system fact resolver.
 */
#pragma once

#include "../posix/operating_system_resolver.hpp"

namespace facter { namespace facts { namespace aix {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : posix::operating_system_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };
}}}  // namespace facter::facts::aix
