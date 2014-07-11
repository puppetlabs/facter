/**
 * @file
 * Declares the Linux processor fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_PROCESSOR_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_PROCESSOR_RESOLVER_HPP_

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
         * Called to resolve processor count, physical processor count, and description facts.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_processors(collection& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_PROCESSOR_RESOLVER_HPP_
