#ifndef LIB_INC_FACTS_LINUX_LSB_RESOLVER_HPP_
#define LIB_INC_FACTS_LINUX_LSB_RESOLVER_HPP_

#include "../fact_resolver.hpp"

namespace cfacter { namespace facts { namespace linux {

    /**
     * Responsible for resolving Linux Standard Base facts.
     */
    struct lsb_resolver : fact_resolver
    {
        // Constants for responsible facts
        constexpr static char const* lsb_dist_id_name = "lsbdistid";
        constexpr static char const* lsb_dist_release_name = "lsbdistrelease";
        constexpr static char const* lsb_dist_codename_name = "lsbdistcodename";
        constexpr static char const* lsb_dist_description_name = "lsbdistdescription";
        constexpr static char const* lsb_dist_maj_release_name = "lsbmajdistrelease";
        constexpr static char const* lsb_dist_minor_release_name = "lsbminordistrelease";
        constexpr static char const* lsb_release_name = "lsbrelease";


        /**
         * Constructs the lsb_resolver.
         */
        lsb_resolver() :
            fact_resolver({
                lsb_dist_id_name,
                lsb_dist_release_name,
                lsb_dist_codename_name,
                lsb_dist_description_name,
                lsb_dist_maj_release_name,
                lsb_dist_minor_release_name,
                lsb_release_name,
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

}}}  // namespace cfacter::facts::linux

#endif  // LIB_INC_FACTS_LINUX_LSB_RESOLVER_HPP_

