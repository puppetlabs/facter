/**
 * @file
 * Declares the solaris operating system fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_OPERATING_SYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_OPERATING_SYSTEM_RESOLVER_HPP_

#include "../posix/operating_system_resolver.hpp"
#include "../scalar_value.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : posix::operating_system_resolver
    {
     protected:
        /**
         * Called to resolve the operating system fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system(collection& facts);

        /**
         * Called to resolve the operating system release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system_release(collection& facts);

        /**
         * Called to resolve the operating system major release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system_major_release(collection& facts);
    };

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_OPERATING_SYSTEM_RESOLVER_HPP_

