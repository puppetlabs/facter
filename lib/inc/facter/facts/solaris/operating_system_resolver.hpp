/**
 * @file
 * Declares the solaris operating system fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_OPERATING_SYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_OPERATING_SYSTEM_RESOLVER_HPP_

#include "../posix/operating_system_resolver.hpp"
#include "../scalar_value.hpp"

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : posix::operating_system_resolver
    {
     protected:
        /**
         * Called to determine the operating system name.
         * @param facts The fact collection that is resolving facts.
         * @returns Returns a string representing the operating system name.
         */
        virtual std::string determine_operating_system(collection& facts);
        /**
         * Called to determine the operating system release.
         * @param facts The fact collection that is resolving facts.
         * @param operating_system The name of the operating system.
         * @returns Returns a string representing the operating system release.
         */
        virtual std::string determine_operating_system_release(collection& facts, std::string const& operating_system);
        /**
         * Called to determine the operating system major release.
         * @param facts The fact collection that is resolving facts.
         * @param operating_system The name of the operating system.
         * @param os_release The version of the operating system.
         * @returns Returns a string representing the operating system major release.
         */
        virtual std::string determine_operating_system_major_release(collection& facts, std::string const& operating_system, std::string const& os_release);
    };

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_OPERATING_SYSTEM_RESOLVER_HPP_

