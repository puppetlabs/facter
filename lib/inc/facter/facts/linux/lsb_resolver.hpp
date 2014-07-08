/**
 * @file
 * Declares the Linux Standard Base (LSB) fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_LSB_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_LSB_RESOLVER_HPP_

#include "../resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving Linux Standard Base facts.
     */
    struct lsb_resolver : resolver
    {
        /**
         * Constructs the lsb_resolver.
         */
        lsb_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);

        /**
         * Called to resolve the LSB dist id fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_dist_id(collection& facts);
        /**
         * Called to resolve the LSB dist release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_dist_release(collection& facts);
        /**
         * Called to resolve the LSB dist codename fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_dist_codename(collection& facts);
        /**
         * Called to resolve the LSB dist description fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_dist_description(collection& facts);
        /**
         * Called to resolve the LSB dist major and minor release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_dist_version(collection& facts);
        /**
         * Called to resolve the LSB release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_release(collection& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_LSB_RESOLVER_HPP_

