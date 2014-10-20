/**
 * @file
 * Declares the Security-Enhanced Linux fact resolver.
 */
#pragma once

#include "../resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving SELinux facts
     */
    struct selinux_resolver : resolver
    {
        /**
         * Constructs the selinux resolver.
         */
        selinux_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Called to resolve all facts read from the SELinux pseudo filesystem.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_selinux_fs_facts(collection& facts);

        /**
         * Called to resolve whether SELinux is enabled and enforcing.
         * @param facts The fact collection that is resolving facts.
         * @param mount The SELinux mount point
         */
        virtual void resolve_selinux_enforce(collection& facts, const std::string& mount);

        /**
         * Called to resolve the SELINUX policy version
         * @param facts The fact collection that is resolving facts.
         * @param mount The SELinux mount point
         */
        virtual void resolve_selinux_policyvers(collection& facts, const std::string& mount);

        /**
         * Called to resolve all facts read from the SELinux configuration file.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_selinux_config_facts(collection& facts);

        /**
         * Gets the selinux pseudo file system mount point.
         * @param selinux_mount Gets the selinux mount point.
         * @returns Returns true if the selinux file system is mounted or false if it is not.
         */
        bool get_selinux_mountpoint(std::string& selinux_mount);
    };

}}}  // namespace facter::facts::linux
