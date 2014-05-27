/**
 * @file
 * Declares the base external fact resolver.
 */
#ifndef FACTER_FACTS_EXTERNAL_RESOLVER_HPP_
#define FACTER_FACTS_EXTERNAL_RESOLVER_HPP_

#include <stdexcept>
#include <string>

namespace facter { namespace facts {
    struct fact_map;
}}  // namespace facter::facts

namespace facter { namespace facts { namespace external {

    /**
     * Thrown when there is an error processing an external fact.
     */
    struct external_fact_exception : std::runtime_error
    {
        /**
         * Constructs a external_fact_exception.
         * @param message The exception message.
         */
        explicit external_fact_exception(std::string const& message);
    };

    /**
     * Base class for external resolvers
     */
    struct resolver
    {
        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact map to populate the external facts into.
         * @return Returns true if the facts were resolved or false if the given file is not supported.
         */
        virtual bool resolve(std::string const& path, fact_map& facts) const = 0;
    };

}}}  // namespace facter::facts::external

#endif  // FACTER_FACTS_EXTERNAL_RESOLVER_HPP_
