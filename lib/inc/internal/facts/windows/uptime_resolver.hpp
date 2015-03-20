/**
 * @file
 * Declares the Windows uptime fact resolver.
 */
#pragma once

#include "../resolvers/uptime_resolver.hpp"
#include "../../util/windows/wmi.hpp"
#include <string>
#include <memory>

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : resolvers::uptime_resolver
    {
        /**
         * Constructs the uptime_resolver.
         * @param wmi_conn The WMI connection to use when resolving facts.
         */
        uptime_resolver(std::shared_ptr<util::windows::wmi> wmi_conn = std::make_shared<util::windows::wmi>());

     protected:
        /**
         * Gets the system uptime in seconds.
         * @return Returns the system uptime in seconds.
         */
        virtual int64_t get_uptime() override;

     private:
        std::shared_ptr<util::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
