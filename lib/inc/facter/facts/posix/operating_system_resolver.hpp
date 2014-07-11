/**
 * @file
 * Declares the POSIX operating system fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : resolver
    {
        /**
         * Constructs the operating_system_resolver.
         */
        operating_system_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
        /**
         * Called to resolve the operating system fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system(collection& facts);
        /**
         * Called to resolve the os family fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_os_family(collection& facts);
        /**
         * Called to resolve the operating system release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system_release(collection& facts);
        /**
         * Called to resolve the operating system major release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system_major_release(collection& facts) {}
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_
