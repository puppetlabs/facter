/**
 * @file
 * Declares the Windows Desktop Management Information (DMI) fact resolver.
 */
#pragma once

#include "../resolvers/disk_resolver.hpp"
#include <leatherman/windows/wmi.hpp>
#include <string>
#include <memory>

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving DMI facts.
     */
    struct disk_resolver : resolvers::disk_resolver
    {
        /**
         * Constructs the dmi_resolver.
         * @param wmi_conn The WMI connection to use when resolving facts.
         */
        dmi_resolver(std::shared_ptr<leatherman::windows::wmi> wmi_conn = std::make_shared<leatherman::windows::wmi>());

     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

     private:
        std::string read(std::string const& path);
        std::shared_ptr<leatherman::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
