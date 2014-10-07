/**
 * @file
 * Declares the Windows processor fact resolver.
 */
#pragma once

#include "../resolvers/processor_resolver.hpp"

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : resolvers::processor_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::windows
