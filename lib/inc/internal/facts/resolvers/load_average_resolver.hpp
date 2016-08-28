/**
 * @file
 * Declares the load average fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <tuple>
#include <boost/optional.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving load_average facts.
     */
    struct load_average_resolver : resolver
    {
        /**
         * Constructs the disk_resolver.
         */
        load_average_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         * @param blocklist A list of facts that should not be collected.
         */
        virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;

    protected:
        /**
         * Get the system load averages (1, 5 or 15 minutes).
         * @return Returns the system load averages.
         */
        virtual boost::optional<std::tuple<double, double, double> > get_load_averages() = 0;
    };

}}}  // namespace facter::facts::resolvers
