/**
 * @file
 * Declares the POSIX networking fact resolver.
 */
#pragma once

#include "../resolvers/networking_resolver.hpp"
#include <sys/socket.h>

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving networking facts.
     */
    struct networking_resolver : resolvers::networking_resolver
    {
        /**
         * Utility function to convert a socket address to a IPv4 or IPv6 string representation.
         * @param addr The socket address to convert to a string.
         * @param mask The mask to apply to the address.
         * @return Returns the IPv4 or IPv6 representation or an empty string if the family isn't supported.
         */
        std::string address_to_string(sockaddr const* addr, sockaddr const* mask = nullptr) const;

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
         * Gets the length of the link address.
         * @param addr The socket address representing the link address.
         * @return Returns the length of the address or 0 if not a link address.
         */
        virtual uint8_t get_link_address_length(sockaddr const* addr) const = 0;

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;
    };

}}}  // namespace facter::facts::posix
