#ifndef FACTER_FACTS_POSIX_UPTIME_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_UPTIME_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving uptime facts.
     */
    struct uptime_resolver : fact_resolver
    {
        /**
         * Constructs the uptime_resolver.
         */
        uptime_resolver() :
            fact_resolver(
            "uptime",
            {
                fact::uptime,
                fact::uptime_days,
                fact::uptime_hours,
                fact::uptime_seconds
            })
        {
        }

        /**
         * Utility function to convert the output of the uptime executable
         * to an int number of seconds.
         * @param output The output of the uptime executable.
         * @return Returns the number of uptime seconds.
         */
        static int parse_executable_uptime(std::string const& output);

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);
        /**
         * Called to resolve the uptime fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_uptime(fact_map& facts);
        /**
         * Called to resolve the uptime days fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_uptime_days(fact_map& facts);
        /**
         * Called to resolve the uptime hours fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_uptime_hours(fact_map& facts);
        /**
         * Called to resolve the uptime seconds fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_uptime_seconds(fact_map& facts);

     private:
        int executable_uptime();
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_UPTIME_RESOLVER_HPP_

