#ifndef LIB_INC_FACTS_POSIX_KERNEL_RESOLVER_HPP_
#define LIB_INC_FACTS_POSIX_KERNEL_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"
#include <sys/utsname.h>

namespace cfacter { namespace facts { namespace posix {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : fact_resolver
    {
        /**
         * Constructs the kernel_resolver.
         */
        kernel_resolver() :
            fact_resolver(
            "kernel",
            {
                fact::kernel,
                fact::kernel_version,
                fact::kernel_release,
                fact::kernel_major_release
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
         * Called to resolve the kernel fact.
         * @param facts The fact map that is resolving facts.
         * @param name The result of the uname call.
         */
        virtual void resolve_kernel(fact_map& facts, utsname const& name);
        /**
         * Called to resolve the kernel release fact.
         * @param facts The fact map that is resolving facts.
         * @param name The result of the uname call.
         */
        virtual void resolve_kernel_release(fact_map& facts, utsname const& name);
        /**
         * Called to resolve the kernel version fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_kernel_version(fact_map& facts);
        /**
         * Called to resolve the kernel major version fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_kernel_major_version(fact_map& facts);
    };

}}}  // namespace cfacter::facts::posix

#endif  // LIB_INC_FACTS_POSIX_KERNEL_RESOLVER_HPP_

