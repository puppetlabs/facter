/**
 * @file
 * Declares the system profiler fact resolver.
 */
#ifndef FACTER_FACTS_OSX_SYSTEM_PROFILER_RESOLVER_HPP_
#define FACTER_FACTS_OSX_SYSTEM_PROFILER_RESOLVER_HPP_

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

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
    };

}}}  // namespace facter::facts::osx

#endif  // FACTER_FACTS_OSX_SYSTEM_PROFILER_RESOLVER_HPP_
