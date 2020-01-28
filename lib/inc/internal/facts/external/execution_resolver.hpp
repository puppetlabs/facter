/**
 * @file
 * Declares the execution external fact resolver.
 */
#pragma once

#include <facter/facts/external/resolver.hpp>

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from executable files.
     */
    struct execution_resolver : resolver
    {
        execution_resolver(std::string const &path):resolver(path) {}

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(collection &facts) const;
    };

}}}  // namespace facter::facts::external
