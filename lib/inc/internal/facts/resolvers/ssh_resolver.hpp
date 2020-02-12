/**
 * @file
 * Declares the base SSH fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <facter/facts/map_value.hpp>
#include <boost/filesystem.hpp>
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

            /**
             * Stores the SSH key type. One of ssh-dss, ssh-rsa, ssh-ed25519,
             * ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, or ecdsa-sha2-nistp512
             */
            std::string type;
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
         * Retrieves the fact's key file
         * @param filename The searched key file name.
         * @return Returns the key file's path
         */
        virtual boost::filesystem::path retrieve_key_file(std::string const& filename) = 0;

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts);

     private:
        void add_key(collection& facts, map_value& value, ssh_key& key, std::string const& name, std::string const& key_fact_name, std::string const& fingerprint_fact_name);
        void populate_key(std::string const& filename, int type, ssh_key& key);
    };

}}}  // namespace facter::facts::resolvers
