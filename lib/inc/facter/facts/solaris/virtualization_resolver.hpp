/**
 * @file
 * Declares the Solaris virtualization fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_VIRTUALIZATION_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_VIRTUALIZATION_RESOLVER_HPP_

#include "../posix/virtualization_resolver.hpp"

namespace facter { namespace facts { namespace solaris {

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

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_VIRTUALIZATION_RESOLVER_HPP_

