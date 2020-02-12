/**
 * @file
 * Declares the YAML external fact resolver.
 */
#pragma once

#include <facter/facts/external/resolver.hpp>

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from YAML files.
     */
    struct yaml_resolver : resolver
    {
        yaml_resolver(std::string const &path):resolver(path) {}

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(collection& facts);
    };

}}}  // namespace facter::facts::external
