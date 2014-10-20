/**
 * @file
 * Declares the base SSH fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include "../map_value.hpp"
#include <string>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving ssh facts.
     */
    struct ssh_resolver : resolver
    {
        /**
         * Constructs the ssh_resolver.
         */
        ssh_resolver();

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents an SSH fingerprint.
         */
        struct fingerprint
        {
            /**
             * Stores the SHA1 fingerprint.
             */
            std::string sha1;

            /**
             * Stores the SHA256 fingerprint.
             */
            std::string sha256;
        };

        /**
         * Represents information about a SSH key.
         */
        struct ssh_key
        {
            /**
             * Stores the SSH key.
             */
            std::string key;

            /**
             * Stores the SSH key's fingerprint.
             */
            fingerprint digest;
        };

        /**
         * Represents SSH resolver data.
         */
        struct data
        {
            /**
             * Stores the DSA key.
             */
            ssh_key dsa;

            /**
             * Stores the RSA key.
             */
            ssh_key rsa;

            /**
             * Stores the ECDSA key.
             */
            ssh_key ecdsa;

            /**
             * Stores the ED25519 key
             */
            ssh_key ed25519;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;

     private:
        void add_key(collection& facts, map_value& value, ssh_key& key, std::string const& name, std::string const& key_fact_name, std::string const& fingerprint_fact_name);
    };

}}}  // namespace facter::facts::resolvers
