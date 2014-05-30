/**
 * @file
 * Declares the JSON external fact resolver.
 */
#ifndef FACTER_FACTS_EXTERNAL_JSON_RESOLVER_HPP_
#define FACTER_FACTS_EXTERNAL_JSON_RESOLVER_HPP_

#include "resolver.hpp"

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from JSON files.
     */
    struct json_resolver : resolver
    {
        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact map to populate the external facts into.
         * @return Returns true if the facts were resolved or false if the given file is not supported.
         */
        virtual bool resolve(std::string const& path, fact_map& facts) const;
    };

}}}  // namespace facter::facts::external

#endif  // FACTER_FACTS_EXTERNAL_JSON_RESOLVER_HPP_
