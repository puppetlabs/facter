/**
 * @file
 * Declares the base external fact resolver.
 */
#pragma once

#include <stdexcept>
#include <string>
#include "../../export.h"
#include "facter/facts/base_resolver.hpp"

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
    struct LIBFACTER_EXPORT resolver : facter::facts::base_resolver
    {
        resolver(std::string const &path);

        /**
         * Resolves facts from the given file.
         * @param path The path to the file to resolve facts from.
         * @param facts The fact collection to populate the external facts into.
         */
        virtual void resolve(collection& facts) = 0;

        /**
         * Gets the name of the fact resolver.
         * @return Returns the fact resolver's name.
         */
        std::string const& name() const;

        /**
         * Gets the fact names the resolver is responsible for resolving.
         * @return Returns a vector of fact names.
         */
        std::vector<std::string> const& names() const;

    protected:
        std::string _path;
        std::string _name;
        std::vector<std::string> _names;
    };

}}}  // namespace facter::facts::external
