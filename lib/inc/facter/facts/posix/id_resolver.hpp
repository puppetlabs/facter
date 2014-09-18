/**
 * @file
 * Declares the User ID resolver
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving the id fact
     */
    struct id_resolver : resolver
    {
        /**
         * Constructs the id resolver.
         */
        id_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);

        /**
         * Called to resolve the id fact using the name of the effective user
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_id(collection& facts);

        /**
         * Called to resolve the id fact using the group of the effective group
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_gid(collection& facts);
    };
}}}  // namespace facter::facts::posix
