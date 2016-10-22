/**
 * @file
 * Declares the Windows networking fact resolver.
 */
#pragma once

#include "../resolvers/networking_resolver.hpp"
#include <vector>
#include <string>
#include <functional>

/*
 * Forward declarations from winsock2.h, ws2tcpip.h, windows.h
 * To use these APIs, include those headers. The headers are not included here
 * to avoid polluting the global namespace.
 */
struct sockaddr;
struct sockaddr_in;
struct sockaddr_in6;

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving networking facts.
     */
    struct networking_resolver : resolvers::networking_resolver
    {
        /**
         * Constructs a Windows networking resolver.
         */
        networking_resolver();

     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

        /**
         * Creates an IPv4 sockaddr_in of the mask. If masklen is too large, returns a full mask.
         * Windows only allows contiguous subnet masks, representing them by their length.
         * @param masklen Length of the contiguous mask.
         * @return The sockaddr_in representation of the mask.
         */
        sockaddr_in create_ipv4_mask(uint8_t masklen);

        /**
         * Creates an IPv6 sockaddr_in6 of the mask. If masklen is too large, returns a full mask.
         * Windows only allows contiguous subnet masks, representing them by their length.
         * @param masklen Length of the contiguous mask.
         * @return The sockaddr_in6 representation of the mask.
         */
        sockaddr_in6 create_ipv6_mask(uint8_t masklen);

        /**
         * Applies a mask to an IPv4 address, returning a new sockaddr_in.
         * @param addr A sockaddr structure defining a valid IPv4 address.
         * @param mask A sockaddr_in structure defining a valid IPv4 mask.
         * @return A new sockaddr_in structure representing the masked IPv4 address.
         */
        static sockaddr_in mask_ipv4_address(sockaddr const* addr, sockaddr_in const& mask);

        /**
         * Applies a mask to an IPv6 address, returning a new sockaddr_in6.
         * @param addr A sockaddr structure defining a valid IPv6 address.
         * @param mask A sockaddr_in6 structure defining a valid IPv6 mask.
         * @return A new sockaddr_in6 structure representing the masked IPv6 address.
         */
        static sockaddr_in6 mask_ipv6_address(sockaddr const* addr, sockaddr_in6 const& mask);
    };

}}}  // namespace facter::facts::windows
