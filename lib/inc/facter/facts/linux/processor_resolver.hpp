/**
 * @file
 * Declares the Linux processor fact resolver.
 */
#pragma once

#include "../posix/processor_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : posix::processor_resolver
    {
     protected:
        /**
         * Called to resolve the hardware architecture fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_architecture(collection& facts);
        /**
         * Called to resolve the processors structured fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_structured_processors(collection& facts);
    };

}}}  // namespace facter::facts::linux
