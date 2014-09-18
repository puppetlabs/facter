/**
 * @file
 * Declares the OSX operating system fact resolver.
 */
#pragma once

#include "../posix/operating_system_resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for collecting system information for the operating system facts.
     */
    struct operating_system_resolver : posix::operating_system_resolver
    {
     protected:
        /**
         * Called to determine the operating system major release.
         * @param facts The fact collection that is resolving facts.
         * @param operating_system The name of the operating system.
         * @param os_release The version of the operating system.
         * @returns Returns a string representing the operating system major release.
         */
        virtual std::string determine_operating_system_major_release(collection& facts, std::string const& operating_system, std::string const& os_release);
        /**
         * Called to determine the operating system minor release.
         * @param facts The fact collection that is resolving facts.
         * @param operating_system The name of the operating system.
         * @param os_release The version of the operating system.
         * @returns Returns a string representing the operating system minor release.
         */
        virtual std::string determine_operating_system_minor_release(collection& facts, std::string const& operating_system, std::string const& os_release);
    };

}}}  // namespace facter::facts::osx
