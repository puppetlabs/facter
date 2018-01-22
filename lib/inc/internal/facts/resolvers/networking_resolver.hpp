/**
 * @file
 * Declares the base networking fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>
#include <facter/facts/map_value.hpp>
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
         * @param bytes The bytes of the MAC address; accepts 6-byte and 20-byte addresses.
         * @param byte_count The number of bytes in the MAC address; defaults to be 6 bytes long.
         * @returns Returns the MAC address as a string or an empty string if the address is the "NULL" MAC address.
         */
        static std::string macaddress_to_string(uint8_t const* bytes, uint8_t byte_count = 6);

        /**
        * Returns whether the address is an ignored IPv4 address.
        * Ignored addresses are local or auto-assigned private IP.
        * @param addr The string representation of an IPv4 address.
        * @return Returns true if an ignored IPv4 address.
        */
        static bool ignored_ipv4_address(std::string const& addr);

        /**
         * Returns whether the address is an ignored IPv6 address. Ignored addresses are local or link-local.
         * @param addr The string representation of an IPv6 address.
         * @return Returns true if an ignored IPv6 address.
         */
        static bool ignored_ipv6_address(std::string const& addr);

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve(collection& facts) override;

     protected:
        /**
         * Represents an address binding.
         */
        struct binding
        {
            /**
             * Stores the interface's address.
             */
            std::string address;

            /**
             * Stores the netmask represented as an address.
             */
            std::string netmask;

            /**
             * Stores the network address.
             */
            std::string network;
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
             * Stores the IPv4 bindings for the interface.
             */
            std::vector<binding> ipv4_bindings;

            /**
             * Stores the IPv6 bindings for the interface.
             */
            std::vector<binding> ipv6_bindings;

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

     private:
        static binding const* find_default_binding(std::vector<binding> const& bindings, std::function<bool(std::string const&)> const& ignored);
        static void add_bindings(interface& iface, bool primary, bool ipv4, collection& facts, map_value& networking, map_value& iface_value);
        interface const* find_primary_interface(std::vector<interface> const& interfaces);
    };

}}}  // namespace facter::facts::resolvers
