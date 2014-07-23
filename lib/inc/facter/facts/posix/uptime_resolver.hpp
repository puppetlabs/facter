/**
 * @file
 * Declares the POSIX uptime fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_UPTIME_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_UPTIME_RESOLVER_HPP_

#include "../resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : resolver
    {
        /**
         * Constructs the uptime_resolver.
         */
        uptime_resolver();

        /**
         * Utility function to parse the output of the uptime executable.
         * @param output The output of the uptime executable.
         * @return Returns the number of uptime seconds.
         */
        static int parse_uptime(std::string const& output);

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
        /**
         * Called to resolve the uptime fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_uptime(collection& facts);
         /**
         * Called to resolve the system_uptime fact.
         * @param facts The fact collection that is resolving facts
         */
        virtual void resolve_system_uptime(collection& facts);
        /**
         * Called to resolve the uptime days fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_uptime_days(collection& facts);
        /**
         * Called to resolve the uptime hours fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_uptime_hours(collection& facts);
        /**
         * Called to resolve the uptime seconds fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_uptime_seconds(collection& facts);

        /**
         * Gets the uptime in seconds.
         * @return Returns the system uptime in seconds.
         */
        virtual int uptime_in_seconds();
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_UPTIME_RESOLVER_HPP_

