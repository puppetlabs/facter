/**
 * @file
 * Declares the Windows virtualization fact resolver.
 */
#pragma once

#include "../resolvers/virtualization_resolver.hpp"
#include <leatherman/windows/wmi.hpp>
#include <string>
#include <memory>

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving virtualization facts.
     */
    struct virtualization_resolver : resolvers::virtualization_resolver
    {
        /**
         * Constructs the virtualization_resolver.
         * @param wmi_conn The WMI connection to use when resolving facts.
         */
        virtualization_resolver(std::shared_ptr<leatherman::windows::wmi> wmi_conn = std::make_shared<leatherman::windows::wmi>());

     protected:
        /**
         * Gets the name of the hypervisor.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the name of the hypervisor or empty string if no hypervisor.
         */
        virtual std::string get_hypervisor(collection& facts) override;

     private:
        std::shared_ptr<leatherman::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
