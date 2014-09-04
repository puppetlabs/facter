/**
 * @file
 * Declares the Solaris processor fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_PROCESSOR_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_PROCESSOR_RESOLVER_HPP_

#include "../posix/processor_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : posix::processor_resolver
    {
     protected:
        /**
         * Called to resolve the processors structured fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_structured_processors(collection& facts);
    };

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_PROCESSOR_RESOLVER_HPP_
