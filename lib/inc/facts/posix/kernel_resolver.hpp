#ifndef __POSIX_KERNEL_RESOLVER_HPP__
#define	__POSIX_KERNEL_RESOLVER_HPP__

#include "../fact_resolver.hpp"

namespace cfacter { namespace facts { namespace posix {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : fact_resolver
    {
        // Constants for responsible facts
        constexpr static char const* kernel_name = "kernel";
        constexpr static char const* kernel_version_name = "kernelversion";
        constexpr static char const* kernel_release_name = "kernelrelease";
        constexpr static char const* kernel_maj_release_name = "kernelmajrelease";

        /**
         * Constructs the kernel_resolver.
         */
        kernel_resolver() :
            fact_resolver({
                kernel_name,
                kernel_version_name,
                kernel_release_name,
                kernel_maj_release_name
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
         */
        virtual void resolve_kernel(fact_map& facts);
        /**
         * Called to resolve the kernel release fact.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_kernel_release(fact_map& facts);
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

}}} // namespace cfacter::facts::posix

#endif

