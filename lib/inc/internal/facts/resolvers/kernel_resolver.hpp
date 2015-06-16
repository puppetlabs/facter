/**
 * @file
 * Declares the base kernel fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>
#include <tuple>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : resolver
    {
        /**
         * Constructs the kernel_resolver.
         */
        kernel_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents kernel data.
         */
        struct data
        {
            /**
             * Stores the name of the kernel (e.g. Linux, Darwin, etc).
             */
            std::string name;

            /**
             * Stores the release of the kernel.
             */
            std::string release;

            /**
             * Stores the major version of the kernel.
             */
            std::string major_version;

            /**
            * Stores the minor version of the kernel.
            */
            std::string minor_version;

            /**
             * Stores the full version of the kernel.
             */
            std::string full_version;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
