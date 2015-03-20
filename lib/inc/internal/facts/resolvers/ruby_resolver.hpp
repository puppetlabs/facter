/**
* @file
* Declares the base Ruby fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving Ruby facts, when a Ruby runtime is available.
    */
    struct ruby_resolver : resolver
    {
        /**
         * Constructs the ruby_resolver.
         */
        ruby_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents Ruby metadata.
         */
        struct data {
            /**
             * Stores RUBY_PLATFORM.
             */
            std::string platform;

            /**
             * Stores the Ruby sitelibdir.
             */
            std::string sitedir;

            /**
             * Stores RUBY_VERSION.
             */
            std::string version;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts);
    };

}}}  // namespace facter::facts::resolvers
