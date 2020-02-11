/**
 * @file
 * Declares the powershell external fact resolver.
 */
#ifndef FACTER_FACTS_EXTERNAL_POWERSHELL_RESOLVER_HPP_
#define FACTER_FACTS_EXTERNAL_POWERSHELL_RESOLVER_HPP_

#include <facter/facts/external/resolver.hpp>

namespace facter { namespace facts { namespace external {

    /**
     * Responsible for resolving facts from powershell scripts.
     */
    struct powershell_resolver : resolver
    {
        powershell_resolver(std::string const &path):resolver(path) {}

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(collection& facts) const;
    };

}}}  // namespace facter::facts::external

#endif  // FACTER_FACTS_EXTERNAL_POWERSHELL_RESOLVER_HPP_
