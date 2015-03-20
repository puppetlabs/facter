/**
 * @file
 * Declares the POSIX uptime fact resolver.
 */
#pragma once

#include "../resolvers/uptime_resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : resolvers::uptime_resolver
    {
        /**
         * Utility function to parse the output of the uptime executable.
         * @param output The output of the uptime executable.
         * @return Returns the number of uptime seconds.
         */
        static int64_t parse_uptime(std::string const& output);

     protected:
        /**
         * Gets the system uptime in seconds.
         * @return Returns the system uptime in seconds.
         */
        virtual int64_t get_uptime() override;
    };

}}}  // namespace facter::facts::posix
