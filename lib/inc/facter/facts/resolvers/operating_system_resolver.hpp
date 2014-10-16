/**
 * @file
 * Declares the base operating system fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : resolver
    {
        /**
         * Constructs the operating_system_resolver.
         */
        operating_system_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents information about an operating system distribution.
         */
        struct distribution
        {
            /**
             * Stores the distribution id.
             */
            std::string id;

            /**
             * Stores the distribution release.
             */
            std::string release;

            /**
             * Stores the distribution codename.
             */
            std::string codename;

            /**
             * Stores the distribution description.
             */
            std::string description;
        };

        /**
         * Represents operating system data.
         */
        struct data
        {
            /**
             * Stores the OS name (e.g. Archlinux).
             */
            std::string name;

            /**
             * Stores the OS release.
             */
            std::string release;

            /**
             * Stores the distribution specification version.
             */
            std::string specification_version;

            /**
             * Stores information about the OS distribution.
             */
            distribution distro;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts);

        /**
         * Parses the major and minor OS release versions.
         * @param name The name of the OS.
         * @param release The release to parse.
         * @return Returns a tuple of major and minor release versions.
         */
        virtual std::tuple<std::string, std::string> parse_release(std::string const& name, std::string const& release) const;

        /**
         * Determines the OS family given an OS name.
         * @param facts The fact collection that is resolving facts.
         * @param name The name of the OS.
         * @return Returns the OS family or empty string if there is no family.
         */
        virtual std::string determine_os_family(collection& facts, std::string const& name) const;
    };

}}}  // namespace facter::facts::resolvers
