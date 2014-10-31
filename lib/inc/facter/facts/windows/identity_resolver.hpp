/**
 * @file
 * Declares the Windows user and group resolver.
 */
#pragma once

#include "../resolvers/identity_resolver.hpp"

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving the user and group facts.
     */
    struct identity_resolver : resolvers::identity_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::windows
