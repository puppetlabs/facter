#ifndef FACTER_FACTS_LINUX_SELINUX_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_SELINUX_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving SELinux facts
     */
    struct selinux_resolver : fact_resolver
    {
        /**
         * Constructs the selinux resolver.
         */
        selinux_resolver() :
            fact_resolver(
            "selinux",
            {
                fact::selinux,
                fact::selinux_enforced,
                fact::selinux_policyversion,
                fact::selinux_current_mode,
                fact::selinux_config_mode,
                fact::selinux_config_policy,
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
         * Called to resolve all facts read from the SELinux pseudo filesystem.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_selinux_fs_facts(fact_map& facts);

        /**
         * Called to resolve whether SELinux is enabled and enforcing.
         * @param facts The fact map that is resolving facts.
         * @param mount The SELinux mount point
         */
        virtual void resolve_selinux_enforce(fact_map& facts, const std::string& mount);

        /**
         * Called to resolve the SELINUX policy version
         * @param facts The fact map that is resolving facts.
         * @param mount The SELinux mount point
         */
        virtual void resolve_selinux_policyvers(fact_map& facts, const std::string& mount);

        /**
         * Called to resolve all facts read from the SELinux configuration file.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_selinux_config_facts(fact_map& facts);

        /**
         * Determine where the selinux pseudo filesystem is mounted.
         */
        bool selinux_fs_mountpoint(std::string& selinux_mount);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_SELINUX_RESOLVER_HPP_

