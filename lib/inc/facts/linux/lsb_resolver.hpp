#ifndef __LINUX_LSB_RESOLVER_HPP__
#define __LINUX_LSB_RESOLVER_HPP__

#include "../fact_resolver.hpp"

namespace cfacter { namespace facts { namespace linux {

    /**
     * Responsible for resolving Linux Standard Base facts.
     */
    struct lsb_resolver : fact_resolver
    {
        // Constants for responsible facts
        constexpr static char const* lsb_dist_id_name = "lsbdistid";

        /**
         * Constructs the lsb_resolver.
         */
        lsb_resolver() :
            fact_resolver({
                lsb_dist_id_name,
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
         * Called to resolve the LSB dist id fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_dist_id(fact_map& facts);
    };

}}} // namespace cfacter::facts::linux

#endif

