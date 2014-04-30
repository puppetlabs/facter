#ifndef FACTER_FACTS_POSIX_PROCESSOR_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_PROCESSOR_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"
#include <string>
#include <sys/utsname.h>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : fact_resolver
    {
        /**
         * Constructs the processor_resolver.
         */
        processor_resolver() :
            fact_resolver(
            "processor",
            {
                fact::processor_count,
                fact::physical_processor_count,
                fact::hardware_isa,
                fact::hardware_model,
            },
            {
                std::string("^") + fact::processor + "[0-9]+$",
            })
        {
        }

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);
        /**
         * Called to resolve the hardware ISA fact.
         * @param facts The fact map that is resolving facts.
         * @param name The result of the uname call.
         */
        virtual void resolve_hardware_isa(fact_map& facts, utsname const& name);
        /**
         * Called to resolve the hardware model fact.
         * @param facts The fact map that is resolving facts.
         * @param name The result of the uname call.
         */
        virtual void resolve_hardware_model(fact_map& facts, utsname const& name);
        /**
         * Called to resolve the hardware architecture fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_architecture(fact_map& facts);
        /**
         * Called to resolve processor count, physical processor count, and description facts.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_processors(fact_map& facts) = 0;
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_PROCESSOR_RESOLVER_HPP_
