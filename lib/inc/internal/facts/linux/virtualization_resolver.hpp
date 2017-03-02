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
        std::string get_hypervisor(collection& facts) override;
        /**
         * Gets the name of the cloud provider.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the name of the cloud provider or empty string if no hypervisor.
         */
        std::string get_cloud_provider(collection& facts) override;

        /**
         * Gets whether the machine is running in Azure.
         * @param facts The fact collection that is resolving facts.
         * @param leases_file The location of where the leases file exists.
         * @return Returns "azure" if running on azure, otherwise an empty string.
         */
        static std::string get_azure(collection& facts, std::string const& leases_file = "/var/lib/dhcp/dhclient.eth0.leases");

     private:
        static std::string get_cgroup_vm();
        static std::string get_gce_vm(collection& facts);
        static std::string get_what_vm();
        static std::string get_vserver_vm();
        static std::string get_vmware_vm();
        static std::string get_openvz_vm();
        static std::string get_xen_vm();
        static std::string get_lspci_vm();
    };

}}}  // namespace facter::facts::linux
