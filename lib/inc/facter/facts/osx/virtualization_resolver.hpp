/**
 * @file
 * Declares the OSX virtualization fact resolver.
 */
#pragma once

#include "../posix/virtualization_resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving virtualization facts.
     */
    struct virtualization_resolver : posix::virtualization_resolver
    {
     protected:
        /**
         * Gets the name of the hypervisor.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the name of the hypervisor or empty string if no hypervisor.
         */
        virtual std::string get_hypervisor(collection& facts);
    };

}}}  // namespace facter::facts::osx
