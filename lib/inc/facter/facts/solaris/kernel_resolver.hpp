/**
 * @file
 * Declares the SOLARIS kernel fact resolver.
 */
#ifndef FACTER_FACTS_SOLARIS_KERNEL_RESOLVER_HPP_
#define FACTER_FACTS_SOLARIS_KERNEL_RESOLVER_HPP_

#include "../posix/kernel_resolver.hpp"
#include <sys/utsname.h>

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : posix::kernel_resolver
    {
     protected:
        /**
         * Called to resolve the kernel version fact.
         * @param facts The fact collection that is resolving facts.
         * @param name The result of the uname call.
         *
         */
        virtual void resolve_kernel_version(collection& facts, struct utsname const& name);
        /**
         * Called to resolve the kernel major version fact.
         * @param facts The fact collection that is resolving facts.
         * @param name The result of the uname call.
         */
        virtual void resolve_kernel_major_version(collection& facts, struct utsname const& name);
    };

}}}  // namespace facter::facts::solaris

#endif  // FACTER_FACTS_SOLARIS_KERNEL_RESOLVER_HPP_

