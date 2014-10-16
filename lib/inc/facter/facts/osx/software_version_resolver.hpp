/**
 * @file
 * Declares the software (OSX) version fact resolver.
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving software (OSX) version facts.
     */
    struct software_version_resolver : resolver
    {
        /**
         * Constructs the software_version_resolver.
         */
        software_version_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;
    };

}}}  // namespace facter::facts::osx
