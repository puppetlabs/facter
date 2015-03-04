/**
 * @file
 * Declares the Linux virtualization fact resolver.
 */
#pragma once

#include "../resolvers/virtualization_resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace linux {

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

     private:
        static std::string get_cgroup_vm();
        static std::string get_gce_vm(collection& facts);
        static std::string get_what_vm();
        static std::string get_vserver_vm();
        static std::string get_vmware_vm();
        static std::string get_openvz_vm();
        static std::string get_xen_vm();
        static std::string get_product_name_vm(collection& facts);
        static std::string get_lspci_vm();
    };

}}}  // namespace facter::facts::linux
