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
         * Represents information about Mac OSX.
         */
        struct mac
        {
            /**
             * Stores the OSX product name.
             */
            std::string product;
            /**
             * Stores the OSX build number.
             */
            std::string build;
            /**
             * Stores the OSX version.
             */
            std::string version;
        };

        /**
         * Represents information about Windows.
         */
        struct windows
        {
            /**
             * Stores the native system32 directory, the location native OS executables can be found.
             * For 32-bit facter on 32-bit Windows, typically: 'C:\\Windows\\system32'.
             * For 32-bit facter on 64-bit Windows, typically: 'C:\\Windows\\sysnative'.
             * For 64-bit facter on 64-bit Windows, typically: 'C:\\Windows\\system32'.
             */
            std::string system32;
        };

        /**
         * Represents information about SELinux.
         */
        struct selinux_data
        {
            /**
             * Default constructor for selinux data.
             */
            selinux_data() :
                supported(false),
                enabled(false),
                enforced(false)
            {
            }

            /**
             * Stores whether or not SELinux is supported.
             */
            bool supported;

            /**
             * Stores whether or not SELinux is enabled.
             */
            bool enabled;

            /**
             * Stores whether or not SELinux is enforced.
             */
            bool enforced;

            /**
             * Stores the SELinux policy version.
             */
            std::string policy_version;

            /**
             * Stores the current SELinux mode.
             */
            std::string current_mode;

            /**
             * Stores the configured SELinux mode.
             */
            std::string config_mode;

            /**
             * Stores the configured SELinux policy.
             */
            std::string config_policy;
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
             * Stores the processor hardware model.
             */
            std::string hardware;

            /**
             * Stores the system architecture.
             */
            std::string architecture;

            /**
             * Stores the distribution specification version.
             */
            std::string specification_version;

            /**
             * Stores information about the OS distribution.
             */
            distribution distro;

            /**
             * Stores information about Mac OSX.
             */
            mac osx;

            /**
             * Stores information about Windows.
             */
            windows win;

            /**
             * Stores information about SELinux.
             */
            selinux_data selinux;
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
