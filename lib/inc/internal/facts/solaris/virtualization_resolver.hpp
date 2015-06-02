/**
 * @file
 * Declares the Solaris virtualization fact resolver.
 */
#pragma once

#include "../resolvers/virtualization_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving virtualization facts.
     */
    struct virtualization_resolver : resolvers::virtualization_resolver
    {
     protected:
        /**
         * Gets the name of the hypervisor.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the name of the hypervisor or empty string if no hypervisor.
         */
        virtual std::string get_hypervisor(collection& facts) override;
    };

}}}  // namespace facter::facts::solaris
