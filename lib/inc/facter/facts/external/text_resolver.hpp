/**
 * @file
 * Declares the text external fact resolver.
 */
#ifndef FACTER_FACTS_EXTERNAL_TEXT_RESOLVER_HPP_
#define FACTER_FACTS_EXTERNAL_TEXT_RESOLVER_HPP_

#include "resolver.hpp"

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from text files.
     */
    struct text_resolver : resolver
    {
        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         * @return Returns true if the facts were resolved or false if the given file is not supported.
         */
        virtual bool resolve(std::string const& path, collection& facts) const;
    };

}}}  // namespace facter::facts::external

#endif  // FACTER_FACTS_EXTERNAL_TEXT_RESOLVER_HPP_
