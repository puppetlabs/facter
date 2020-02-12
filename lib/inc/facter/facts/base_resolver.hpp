#ifndef BASE_RESOLVER_H
#define BASE_RESOLVER_H

#include "../export.h"
#include <vector>
#include <string>

namespace facter { namespace facts {
    struct collection;
    struct LIBFACTER_EXPORT base_resolver
    {
         /**
         * Gets the name of the fact resolver.
         * @return Returns the fact resolver's name.
         */
        virtual std::string const& name() const = 0;

        /**
         * Gets the fact names the resolver is responsible for resolving.
         * @return Returns a list of fact names.
         */
        virtual std::vector<std::string> const& names() const = 0;

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) = 0;
    };
}}  // namespace facter::facts

#endif  // BASE_RESOLVER_H
