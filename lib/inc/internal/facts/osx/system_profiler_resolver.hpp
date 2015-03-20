/**
 * @file
 * Declares the system profiler fact resolver.
 */
#pragma once

#include "../resolvers/system_profiler_resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving system profiler facts.
     */
    struct system_profiler_resolver : resolvers::system_profiler_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::osx
