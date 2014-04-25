#ifndef FACTER_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : fact_resolver
    {
        /**
         * Constructs the operating_system_resolver.
         */
        operating_system_resolver() :
            fact_resolver(
            "operating system",
            {
                fact::operating_system,
                fact::os_family,
                fact::operating_system_release,
                fact::operating_system_major_release
            })
        {
        }

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        void resolve_facts(fact_map& facts);
        /**
         * Called to resolve the operating system fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_operating_system(fact_map& facts);
        /**
         * Called to resolve the os family fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_os_family(fact_map& facts);
        /**
         * Called to resolve the operating system release fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_operating_system_release(fact_map& facts);
        /**
         * Called to resolve the operating system major release fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_operating_system_major_release(fact_map& facts) {}
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_
