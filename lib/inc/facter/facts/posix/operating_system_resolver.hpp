/**
 * @file
 * Declares the POSIX operating system fact resolver.
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : resolver
    {
        /**
         * Constructs the operating_system_resolver.
         */
        operating_system_resolver();

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);
        /**
         * Called to resolve the OS structured fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_structured_operating_system(collection& facts);
        /**
         * Called to resolve the operating system fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system(collection& facts);
        /**
         * Called to resolve the os family fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_os_family(collection& facts);
        /**
         * Called to resolve the operating system release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system_release(collection& facts);
        /**
         * Called to resolve the operating system major release fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system_major_release(collection& facts);
        /**
         * Called to determine the operating system name.
         * @param facts The fact collection that is resolving facts.
         * @returns Returns a string representing the operating system name.
         */
        virtual std::string determine_operating_system(collection& facts);
        /**
         * Called to determine the operating system family.
         * @param facts The fact collection that is resolving facts.
         * @param operating_system The name of the operating system.
         * @returns Returns a string representing the operaing system family.
         */
        virtual std::string determine_os_family(collection& facts, std::string const& operating_system);
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
        /**
         * Called to determine the operatingsystem minor release.
         * @param facts The fact collection that is resolving facts.
         * @param operating_system The name of the operating system.
         * @param os_release The version of the operating system
         * @returns Returns a string representing the operating system minor release.
         */
        virtual std::string determine_operating_system_minor_release(collection& facts, std::string const& operating_system, std::string const& os_release);
    };

}}}  // namespace facter::facts::posix
