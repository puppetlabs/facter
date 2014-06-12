/**
 * @file
 * Declares the Linux virtualization fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_VIRTUALIZATION_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_VIRTUALIZATION_RESOLVER_HPP_

#include "../posix/virtualization_resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving virtualization facts.
     */
    struct virtualization_resolver : posix::virtualization_resolver
    {
     protected:
        /**
         * Gets the name of the hypervisor.
         * @param facts The fact map that is resolving facts.
         * @return Returns the name of the hypervisor or empty string if no hypervisor.
         */
        virtual std::string get_hypervisor(fact_map& facts);

     private:
        static std::string get_cgroup_vm();
        static std::string get_gce_vm(fact_map& facts);
        static std::string get_what_vm();
        static std::string get_vserver_vm();
        static std::string get_vmware_vm();
        static std::string get_openvz_vm();
        static std::string get_xen_vm();
        static std::string get_product_name_vm(fact_map& facts);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_VIRTUALIZATION_RESOLVER_HPP_

