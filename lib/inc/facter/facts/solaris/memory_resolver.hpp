/**
 * @file
 * Declares the Solaris memory fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_MEMORY_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_MEMORY_RESOLVER_HPP_

#include "../posix/memory_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving memory facts.
     */
    struct memory_resolver : posix::memory_resolver
    {
     protected:
        /**
         * Called to get the memory statistics.
         * @param facts The fact collection that is resolving facts.
         * @param mem_free The returned free memory amount.
         * @param mem_total The returned total memory amount.
         * @param swap_free The returned free swap amount.
         * @param swap_total The returned total swap amount.
         * @return Returns true if memory statistics is available or false if it is not.
         */
        virtual bool get_memory_statistics(
            collection& facts,
            uint64_t& mem_free,
            uint64_t& mem_total,
            uint64_t& swap_free,
            uint64_t& swap_total);
    };

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_MEMORY_RESOLVER_HPP_
