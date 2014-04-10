#ifndef LIB_INC_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_
#define LIB_INC_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_

#include "../fact_resolver.hpp"

namespace cfacter { namespace facts { namespace posix {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : fact_resolver
    {
        // Constants for responsible facts
        constexpr static char const* operating_system_name = "operatingsystem";

        /**
         * Constructs the operating_system_resolver.
         */
        operating_system_resolver() :
            fact_resolver({
                operating_system_name,
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
    };

}}}  // namespace cfacter::facts::posix

#endif  // LIB_INC_FACTS_POSIX_OPERATING_SYSTEM_RESOLVER_HPP_

