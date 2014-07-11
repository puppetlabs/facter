/**
 * @file
 * Declares the Linux operating system fact resolver.
 */
#ifndef FACTER_FACTS_LINUX_OPERATING_SYSTEM_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_OPERATING_SYSTEM_RESOLVER_HPP_

#include "../posix/operating_system_resolver.hpp"
#include "../scalar_value.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : posix::operating_system_resolver
    {
     protected:
        /**
         * Called to resolve the operating system fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_operating_system(collection& facts);

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

     private:
        static std::string check_cumulus_linux();
        static std::string check_debian_linux(string_value const* dist_id);
        static std::string check_oracle_linux();
        static std::string check_redhat_linux();
        static std::string check_suse_linux();
        static std::string check_other_linux();
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_OPERATING_SYSTEM_RESOLVER_HPP_

