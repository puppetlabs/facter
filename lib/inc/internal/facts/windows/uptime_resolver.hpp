/**
 * @file
 * Declares the Windows uptime fact resolver.
 */
#pragma once

#include "../resolvers/uptime_resolver.hpp"
#include <leatherman/windows/wmi.hpp>
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
        uptime_resolver(std::shared_ptr<leatherman::windows::wmi> wmi_conn = std::make_shared<leatherman::windows::wmi>());

     protected:
        /**
         * Gets the system uptime in seconds.
         * @param facts The fact collection.
         * @return Returns the system uptime in seconds.
         */
        virtual int64_t get_uptime(collection& facts) override;

     private:
        std::shared_ptr<leatherman::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
