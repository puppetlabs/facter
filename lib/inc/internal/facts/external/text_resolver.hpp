/**
 * @file
 * Declares the text external fact resolver.
 */
#pragma once

#include <facter/facts/external/resolver.hpp>

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from text files.
     */
    struct text_resolver : resolver
    {
        /**
         * Determines if the resolver can resolve the facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @return Returns true if the resolver can resolve the facts in the given file or false if it cannot.
         */
        virtual bool can_resolve(std::string const& path) const;

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(std::string const& path, collection& facts) const;
    };

}}}  // namespace facter::facts::external
