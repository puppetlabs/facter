/**
 * @file
 * Declares the posix load average fact resolver.
 */
#pragma once

#include "../resolvers/load_average_resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving the load average facts.
     */
    struct load_average_resolver : resolvers::load_average_resolver
    {
     protected:
        /**
         * Gets the load averages (for 1, 5 and 15 minutes period).
         */
        virtual boost::optional<std::tuple<double, double, double> > get_load_averages() override;
    };

}}}  // namespace facter::facts::posix
