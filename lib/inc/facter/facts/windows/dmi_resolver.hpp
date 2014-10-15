/**
 * @file
 * Declares the Windows Desktop Management Information (DMI) fact resolver.
 */
#pragma once

#include "../resolvers/dmi_resolver.hpp"
#include <facter/util/windows/wmi.hpp>
#include <string>
#include <memory>

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving DMI facts.
     */
    struct dmi_resolver : resolvers::dmi_resolver
    {
        /**
         * Constructs the dmi_resolver, specifying the WMI connection to use
         */
        dmi_resolver(std::shared_ptr<util::windows::wmi> wmi_conn = std::make_shared<util::windows::wmi>());

     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

     private:
        std::string read(std::string const& path);
        std::shared_ptr<util::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
