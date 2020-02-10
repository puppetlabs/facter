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
     * Thrown when there is no external resolver for a file
     */
    struct LIBFACTER_EXPORT external_fact_no_resolver : std::runtime_error
    {
        explicit external_fact_no_resolver(std::string const& message);
    };

    /**
     * Base class for external resolvers
     */
    struct LIBFACTER_EXPORT resolver
    {
        resolver(std::string const &path):_path(path) {}

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(collection& facts) const = 0;
    protected:
        std::string _path;
    };

}}}  // namespace facter::facts::external
