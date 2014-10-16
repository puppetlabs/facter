/**
 * @file
 * Declares the system profiler fact resolver.
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving system profiler facts.
     */
    struct system_profiler_resolver : resolver
    {
        /**
         * Constructs the system_profiler_resolver.
         */
        system_profiler_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;
    };

}}}  // namespace facter::facts::osx
