/**
 * @file
 * Declares the base external fact resolver.
 */
#pragma once

#include <stdexcept>
#include <string>
#include "../../export.h"

namespace facter { namespace facts {
    struct collection;
}}  // namespace facter::facts

namespace facter { namespace facts { namespace external {

    /**
     * Thrown when there is an error processing an external fact.
     */
    struct LIBFACTER_EXPORT external_fact_exception : std::runtime_error
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
    struct LIBFACTER_EXPORT resolver
    {
        /**
         * Determines if the resolver can resolve the facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @return Returns true if the resolver can resolve the facts in the given file or false if it cannot.
         */
        virtual bool can_resolve(std::string const& path) const = 0;

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(std::string const& path, collection& facts) const = 0;
    };

}}}  // namespace facter::facts::external
