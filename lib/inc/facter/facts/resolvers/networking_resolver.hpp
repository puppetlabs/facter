/**
 * @file
 * Declares the base networking fact resolver.
 */
#pragma once

#include "../resolver.hpp"
#include <string>
#include <vector>
#include <boost/optional.hpp>

namespace facter { namespace facts { namespace resolvers {

    /**
     * Responsible for resolving networking facts.
     */
    struct networking_resolver : resolver
    {
        /**
         * Constructs the networking_resolver.
         */
        networking_resolver();

        /**
         * Utility function to convert the bytes of a MAC address to a string.
         * @param bytes The bytes of the MAC address; expected to be 6 bytes long.
         * @returns Returns the MAC address as a string or an empty string if the address is the "NULL" MAC address.
         */
        static std::string macaddress_to_string(uint8_t const* bytes);

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents an IP address.
         */
        struct ipaddress
        {
            /**
             * Stores the IPv4 address.
             */
            std::string v4;

            /**
             * Stores the IPv6 address.
             */
            std::string v6;
        };

        /**
         * Represents a network interface.
         */
        struct interface
        {
            /**
             * Stores the name of the interface.
             */
            std::string name;

            /**
             * Stores the DHCP server address.
             */
            std::string dhcp_server;

            /**
             * Stores the interface's address.
             */
            ipaddress address;

            /**
             * Stores the netmask represented as an address.
             */
            ipaddress netmask;

            /**
             * Stores the network address.
             */
            ipaddress network;

            /**
             * Stores the link layer (MAC) address.
             */
            std::string macaddress;

            /**
             * Stores the interface MTU.
             */
            boost::optional<uint64_t> mtu;
        };

        /**
         * Represents the resolver's data.
         */
        struct data
        {
            /**
             * Stores the hostname.
             */
            std::string hostname;

            /**
             * Stores the domain.
             */
            std::string domain;

            /**
             * Stores the FQDN.
             */
            std::string fqdn;

            /**
             * Stores the name of the primary interface.
             */
            std::string primary_interface;

            /**
             * Stores the interface.
             */
            std::vector<interface> interfaces;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
