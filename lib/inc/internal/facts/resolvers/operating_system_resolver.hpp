/**
 * @file
 * Declares the base operating system fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
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

        /**
         * Parses the major and minor OS release versions for Linux distros.
         * @param name The name of the OS.
         * @param release The release to parse.
         * @return Returns a tuple of major and minor release versions.
         */
        static std::tuple<std::string, std::string> parse_distro(std::string const& name, std::string const& release);

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
             * Stores the Windows Server or Desktop Edition variant 
             */
            std::string edition_id;
            /**
             * Stores the Windows differentiate Server, Server Core, Client (Desktop)
             */
            std::string installation_type;
            /**
             * Stores the Windows textual product name
             */
            std::string product_name;
            /**
             * Stores the Windows Build Version.
             */
            std::string release_id;
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
             * Stores the OS name (e.g. CentOS).
             */
            std::string name;

            /**
             * Stores the OS family name (e.g. Debian).
             */
            std::string family;

            /**
             * Stores the OS release.
             */
            std::string release;

            /**
             * Stores the OS major release.
             */
            std::string major;

            /**
             * Stores the OS minor release.
             */
            std::string minor;

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
         * Collects the resolver's kernel data.
         * @param facts The fact collection that is resolving facts.
         * @param result The current resolver data.
         */
        virtual void collect_kernel_data(collection& facts, data &result);

        /**
         * Collects the resolver's release data.
         * @param facts The fact collection that is resolving facts.
         * @param result The current resolver data.
         */
        virtual void collect_release_data(collection& facts, data &result);
    };

}}}  // namespace facter::facts::resolvers
