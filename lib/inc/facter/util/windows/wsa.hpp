/**
 * @file
 * Declares utility functions for interacting with Winsock
 */
#pragma once

#include <facter/util/windows/windows.hpp>
#include <string>
#include <stdexcept>

namespace facter { namespace util { namespace windows {

    /**
     * Exception thrown when wsa initialization fails.
     */
    struct wsa_exception : std::runtime_error
    {
        /**
         * Constructs a wsa_exception.
         * @param message The exception message.
         */
        explicit wsa_exception(std::string const& message);
    };

    /**
     * A class for initiating use of the Winsock DLL, providing wrappers for WSA calls.
     */
    struct wsa {
        /**
         * Initializes Winsock. Throws a wsa_exception on failure.
         */
        wsa();

        /**
         * Do WSA cleanup.
         */
        ~wsa();

        /**
         * Disable copy constructor; there's no reason to make a copy over a new instance.
         */
        wsa(wsa const&) = delete;

        /**
         * Disable copy assignment; there's no reason to make a copy over a new instance.
         */
        wsa& operator=(wsa const&) = delete;

        /**
         * Use default move constructer.
         */
        wsa(wsa&&) = default;

        /**
         * Use default move assignment.
         */
        wsa& operator=(wsa&&) = default;

        /**
         * This wraps calling WSAAddressToString to translate a sockaddr structure to an IPv4 or IPv6 string.
         * Throws an exception if passed an IPv6 argument on Windows Server 2003 and IPv6 support isn't installed.
         * See https://social.technet.microsoft.com/Forums/windowsserver/en-US/7166dcbe-d493-4da1-8441-5b5d6aa0d21c/ipv6-and-windows-server-2003
         * @param addr The socket address structure.
         * @return An IPv4 or IPv6 string.
         */
        std::string saddress_to_string(SOCKET_ADDRESS const& addr) const;

        /**
         * This adapts sockaddr structs to the SOCKET_ADDRESS wrapper.
         * @param addr A sockaddr-like structure (sockaddr, sockaddr_in, sockaddr_in6).
         * @return An IPv4 or IPv6 string.
         */
        template<typename T>
        std::string address_to_string(T &addr) const
        {
            return saddress_to_string(SOCKET_ADDRESS{reinterpret_cast<sockaddr *>(&addr), sizeof(T)});
        }

        /**
         * This wraps calling WSAStringToAddress to translate a an IPv4 or IPv6 string to a sockaddr structure.
         * @tparam T The expected sockaddr structure, either sockaddr_in or sockaddr_in6.
         * @tparam ADDRESS_FAMILY The expected address family, either AF_INET or AF_INET6.
         * @param addr An IPv4 or IPv6 string.
         * @return A sockaddr structure containing the IPv4 or IPv6 sockaddr data.
         */
        template<typename T, int ADDRESS_FAMILY>
        T string_to_address(std::string const& addr) const
        {
            T sock = {ADDRESS_FAMILY};
            string_fill_sockaddr(reinterpret_cast<sockaddr*>(&sock), addr, sizeof(T));
            return sock;
        }

     private:
        void string_fill_sockaddr(sockaddr *sock, std::string const& addr, int size) const;
    };

}}}  // namespace facter::util::windows
