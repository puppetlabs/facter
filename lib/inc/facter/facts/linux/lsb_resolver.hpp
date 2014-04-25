#ifndef FACTER_FACTS_LINUX_LSB_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_LSB_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving Linux Standard Base facts.
     */
    struct lsb_resolver : fact_resolver
    {
        /**
         * Constructs the lsb_resolver.
         */
        lsb_resolver() :
            fact_resolver(
            "Linux Standard Base",
            {
                fact::lsb_dist_id,
                fact::lsb_dist_release,
                fact::lsb_dist_codename,
                fact::lsb_dist_description,
                fact::lsb_dist_major_release,
                fact::lsb_dist_minor_release,
                fact::lsb_release,
            })
        {
        }

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);

        /**
         * Called to resolve the LSB dist id fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_dist_id(fact_map& facts);
        /**
         * Called to resolve the LSB dist release fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_dist_release(fact_map& facts);
        /**
         * Called to resolve the LSB dist codename fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_dist_codename(fact_map& facts);
        /**
         * Called to resolve the LSB dist description fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_dist_description(fact_map& facts);
        /**
         * Called to resolve the LSB dist major and minor release fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_dist_version(fact_map& facts);
        /**
         * Called to resolve the LSB release fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_release(fact_map& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_LSB_RESOLVER_HPP_

