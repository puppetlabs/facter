/**
 * @file
 * Declares the base class for fact resolvers.
 */
#pragma once

#include "../export.h"
#include <vector>
#include <memory>
#include <stdexcept>
#include <string>
#include <boost/regex.hpp>

namespace facter { namespace facts {

    /**
     * Thrown when a resolver is constructed with an invalid fact name pattern.
     */
    struct LIBFACTER_EXPORT invalid_name_pattern_exception : std::runtime_error
    {
        /**
         * Constructs a invalid_name_pattern_exception.
         * @param message The exception message.
         */
        explicit invalid_name_pattern_exception(std::string const& message);
    };

    struct collection;

    /**
     * Base class for fact resolvers.
     * A fact resolver is responsible for resolving one or more facts.
     * This type can be moved but cannot be copied.
     */
    struct LIBFACTER_EXPORT resolver
    {
        /**
         * Constructs a resolver.
         * @param name The fact resolver name.
         * @param names The fact names the resolver is responsible for.
         * @param patterns Regular expression patterns for additional ("dynamic") facts the resolver is responsible for.
         */
        resolver(std::string name, std::vector<std::string> names, std::vector<std::string> const& patterns = {});

        /**
         * Destructs the resolver.
         */
        virtual ~resolver();

        /**
         * Prevents the resolver from being copied.
         */
        resolver(resolver const&) = delete;

        /**
         * Prevents the resolver from being copied.
         * @returns Returns this resolver.
         */
        resolver& operator=(resolver const&) = delete;

        /**
         * Moves the given resolver into this resolver.
         * @param other The resolver to move into this resolver.
         */
        // Visual Studio 12 still doesn't allow default for move constructor.
        resolver(resolver&& other);

        /**
         * Moves the given resolver into this resolver.
         * @param other The resolver to move into this resolver.
         * @return Returns this resolver.
         */
        // Visual Studio 12 still doesn't allow default for move assignment.
        resolver& operator=(resolver&& other);

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

        /**
         * Determines if the resolver has patterns.
         * @return Returns true if the resolver has patterns or false if it does not.
         */
        bool has_patterns() const;

        /**
         * Determines if the given name matches a pattern for the resolver.
         * @param name The fact name to check.
         * @return Returns true if the name matches a pattern or returns false if it does not.
         */
        bool is_match(std::string const& name) const;

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) = 0;

     private:
        std::string _name;
        std::vector<std::string> _names;
        std::vector<boost::regex> _regexes;
    };

}}  // namespace facter::facts
