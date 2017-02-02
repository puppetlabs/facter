/**
* @file
* Declares the base virtualization fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>

namespace facter { namespace facts { namespace resolvers {

    /**
     *  Represents cloud data.
     */
    struct cloud_
    {
        /**
         * Stores the cloud provider.
         */
        std::string provider;
    };

    /**
     *  Represents virtualization data.
     */
    struct data
    {
        /**
         * Stores the cloud data.
         */
        cloud_ cloud;
        /**
         * Stores the hypervisor data.
         */
        std::string hypervisor;
        /**
         * Stores the is_virtual data.
         */
        bool is_virtual;
    };

    /**
     * Responsible for resolving virtualization facts.
     */
    struct virtualization_resolver : resolver
    {
        /**
         * Constructs the virtualization_resolver.
         */
        virtualization_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Gets the name of the hypervisor.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the name of the hypervisor or empty string if no hypervisor.
         */
        virtual std::string get_hypervisor(collection& facts) = 0;

        /**
         * Gets the name of the cloud provider.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the name of the cloud provider or empty string if no cloud provider.
         */
        virtual std::string get_cloud_provider(collection& facts);

        /**
         * Determines if the given hypervisor is considered to be virtual.
         * @param hypervisor The hypervisor to check.
         * @return Returns true if the hypervisor is virtual or false if it is physical.
         */
        virtual bool is_virtual(std::string const& hypervisor);

        /**
         * Gets the product name which is matched against a list of known
         * hypervisors.
         * @param product_name The product_name fact to match against.
         * @return Returns the hypervisor product name if matched.
         */
        static std::string get_product_name_vm(std::string const& product_name);

        /**
         * Collects the virtualization data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the virtualization data.
         */
        virtual data collect_data(collection& facts);
    };

}}}  // namespace facter::facts::resolvers
