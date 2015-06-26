/**
 * @file
 * Declares the Xen fact resolver on POSIX systems.
 */
#pragma once

#include <internal/facts/resolvers/xen_resolver.hpp>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving Xen facts.
     */
    struct xen_resolver : resolvers::xen_resolver
    {
     protected:
        /**
         * Gets the Xen management command.
         * @return Returns the Xen management command.
         */
        virtual std::string xen_command();
    };

}}}  // namespace facter::facts::posix
