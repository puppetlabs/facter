#ifndef FACTER_FACTS_OSX_PROCESSOR_RESOLVER_HPP_
#define FACTER_FACTS_OSX_PROCESSOR_RESOLVER_HPP_

#include "../posix/processor_resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : posix::processor_resolver
    {
     protected:
        /**
         * Called to resolve processor count, physical processor count, and description facts.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_processors(fact_map& facts);
    };

}}}  // namespace facter::facts::osx

#endif  // FACTER_FACTS_OSX_PROCESSOR_RESOLVER_HPP_
