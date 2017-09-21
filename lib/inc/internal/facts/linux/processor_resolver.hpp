/**
 * @file
 * Declares the Linux processor fact resolver.
 */
#pragma once

#include "../posix/processor_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : posix::processor_resolver
    {
     protected:
       /**
        * Adds the cpu-specific data to the currently collected data.
        * @param data The currently collected data
        * @param root Path to the root directory of the system
        */
        void add_cpu_data(data& data, std::string const& root = "");

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::linux
