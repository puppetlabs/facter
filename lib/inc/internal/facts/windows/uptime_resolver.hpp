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
         */
        uptime_resolver();

     protected:
        /**
         * Gets the system uptime in seconds.
         * @return Returns the system uptime in seconds.
         */
        virtual int64_t get_uptime() override;
    };

}}}  // namespace facter::facts::windows
