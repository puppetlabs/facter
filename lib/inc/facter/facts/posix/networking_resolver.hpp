/**
 * @file
 * Declares the POSIX networking fact resolver.
 */
#ifndef FACTER_FACTS_POSIX_NETWORKING_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_NETWORKING_RESOLVER_HPP_

#include "../resolver.hpp"
#include <string>
#include <sys/socket.h>

namespace facter { namespace facts { namespace posix {

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
         * Utility function to convert a socket address to a IPv4 or IPv6 string representation.
         * @param addr The socket address to convert to a string.
         * @param mask The mask to apply to the address.
         * @return Returns the IPv4 or IPv6 representation or an empty string if the family isn't supported.
         */
        std::string address_to_string(sockaddr const* addr, sockaddr const* mask = nullptr) const;

        /**
         * Utility function to convert the bytes of a MAC address to a string.
         * @param bytes The bytes of the MAC address; expected to be 6 bytes long.
         * @returns Returns the MAC address as a string or an empty string if the address is the "NULL" MAC address.
         */
        static std::string macaddress_to_string(uint8_t const* bytes);

     protected:
        /**
         * Determines if the given sock address is a link layer address.
         * @param addr The socket address to check.
         * @returns Returns true if the socket address is a link layer address or false if it is not.
         */
        virtual bool is_link_address(sockaddr const* addr) const = 0;

        /**
         * Gets the bytes of the link address.
         * @param addr The socket address representing the link address.
         * @return Returns a pointer to the address bytes or nullptr if not a link address.
         */
        virtual uint8_t const* get_link_address_bytes(sockaddr const* addr) const = 0;

        /**
         * Gets the MTU of the link layer data.
         * @param interface The name of the link layer interface.
         * @param data The data pointer from the link layer interface.
         * @return Returns The MTU of the interface or -1 if there's no MTU.
         */
        virtual int get_link_mtu(std::string const& interface, void* data) const = 0;

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_facts(collection& facts);

        /**
         * Called to resolve the hostname fact.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_hostname(collection& facts);

        /**
         * Called to resolve the domain and fqdn facts.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_domain(collection& facts);

        /**
         * Called to resolve interface facts.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_interface_facts(collection& facts) = 0;
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_NETWORKING_RESOLVER_HPP_
