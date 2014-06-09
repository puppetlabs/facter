/**
 * @file
 * Declares the POSIX virtualization fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_VIRTUALIZATION_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_VIRTUALIZATION_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving virtualization facts.
     */
    struct virtualization_resolver : fact_resolver
    {
        /**
         * Constructs the virtualization_resolver.
         */
        virtualization_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);

        /**
         * Gets the name of the hypervisor.
         * @param facts The fact map that is resolving facts.
         * @return Returns the name of the hypervisor or empty string if no hypervisor.
         */
        virtual std::string get_hypervisor(fact_map& facts) = 0;

        /**
         * Determines if the given hypervisor means the machine is virtual.
         * @param hypervisor The name of the hypervisor.
         * @return Returns true if the machine is virtual or false if it is physical.
         */
        virtual bool is_virtual(std::string const& hypervisor);
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_VIRTUALIZATION_RESOLVER_HPP_

