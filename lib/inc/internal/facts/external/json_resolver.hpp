/**
 * @file
 * Declares the JSON external fact resolver.
 */
#pragma once

#include <facter/facts/external/resolver.hpp>

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from JSON files.
     */
    struct json_resolver : resolver
    {
        json_resolver(std::string const &path):resolver(path) {}

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(collection& facts);
    };

}}}  // namespace facter::facts::external
