/**
 * @file
 * Declares the Linux processor fact resolver.
 */
#pragma once

#include "../posix/processor_resolver.hpp"
#include <functional>

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : posix::processor_resolver
    {
     protected:
        /**
         * The architecture type of the linux machine.
         */ 
        enum class ArchitectureType {POWER, X86};

	/**
	 * The check consists of the following.
	 *   (1) Check the previously computed isa fact. If it starts with
	 *   ppc64, then we have a power machine.
	 *
	 *   (2) If (1) is empty (possible because exec might have failed to obtain
	 *   the isa fact), then we use /proc/cpuinfo by checking whether that file
	 *   contains the "cpu", "clock", and "revision" keys -- these keys are only
	 *   found in Power machines.
         *
         * @param data The currently collected data
         * @param root Path to the root directory of the system
         * @return Returns the architecture type of the machine
	 */ 
        ArchitectureType architecture_type(data const& data, std::string const& root);

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

     private:
        void maybe_add_speed(data& data, std::string const& speed);
        bool compute_cpu_counts(data& data, std::string const& root, std::function<bool(std::string const&)> is_valid_id);
        bool add_x86_cpu_data(data& data, std::string const& root = "");
        bool add_power_cpu_data(data& data, std::string const& root = "");
    };

}}}  // namespace facter::facts::linux
