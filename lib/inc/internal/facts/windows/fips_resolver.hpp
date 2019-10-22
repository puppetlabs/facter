/**
 * @file
 * Declares the Windows fips fact resolver.
 */
#pragma once

#include "../resolvers/fips_resolver.hpp"

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving fips-related facts.
     */
    struct fips_resolver : resolvers::fips_resolver
    {
     protected:
        /**
         * The check consists of the following.
         *   (1) Examining the contents of
         *   HKEY_LOCAL_MACHINE/System/CurrentControlSet/Control/Lsa/FipsAlgorithmPolicy/Enabled
         *
         *   If it is 1 then fips mode is enabled.
         */

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::windows
