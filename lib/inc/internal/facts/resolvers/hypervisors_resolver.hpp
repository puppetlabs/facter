/**
 * @file
 * Declares the hypervisors fact resolver
 */
#pragma once

#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/fact.hpp>
#include <boost/variant.hpp>
#include <string>
#include <unordered_map>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Represents hypervisor data collected from libwhereami
     */
    using hypervisor_data = std::unordered_map<std::string, std::unordered_map<std::string, boost::variant<std::string, bool, int>>>;

    /**
     * This base resolver exists to allow libfacter schema tests to pass when libwhereami is not included in the build.
     */
    struct hypervisors_resolver_base : resolver
    {
        /**
         * Default constructor
         */
        hypervisors_resolver_base() :
            resolver(
                "hypervisors",
                {
                    fact::hypervisors
                })
        {
        }

        /**
         * Called to resolve all facts the resolver is responsible for
         * @param facts The fact collection that is resolving the facts
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Collects hypervisor data
         * @param facts
         * @return Returns the hypervisor data.
         */
        virtual hypervisor_data collect_data(collection& facts) = 0;
    };

    /**
     * Hypervisors resolver for use when libwhereami is included
     */
    struct hypervisors_resolver : hypervisors_resolver_base
    {
        /**
         * Collects hypervisor data
         * @param facts
         * @return Returns the hypervisor data.
         */
        virtual hypervisor_data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::resolvers
