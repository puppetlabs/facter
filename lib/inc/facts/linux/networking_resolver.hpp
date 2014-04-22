#ifndef LIB_INC_FACTS_LINUX_NETWORKING_RESOLVER_HPP_
#define LIB_INC_FACTS_LINUX_NETWORKING_RESOLVER_HPP_

#include "../bsd/networking_resolver.hpp"

namespace cfacter { namespace facts { namespace linux {

    /**
     * Responsible for resolving networking facts.
     *
     * The Linux networking_resolver inherits from the BSD networking_resolver.
     * This is because getifaddrs is a BSD concept that was implemented in Linux.
     * The only thing this resolver is responsible for is handing link-level
     * addressing and MTU.
     */
    struct networking_resolver : bsd::networking_resolver
    {
     protected:
        /**
         * Determines if the given sock address is a link layer address.
         * @param addr The socket address to check.
         * @returns Returns true if the socket address is a link layer address or false if it is not.
         */
        virtual bool is_link_address(sockaddr const* addr) const;

        /**
         * Gets the bytes of the link address.
         * @param addr The socket address representing the link address.
         * @return Returns a pointer to the address bytes or nullptr if not a link address.
         */
        virtual uint8_t const* get_link_address_bytes(sockaddr const* addr) const;

        /**
         * Gets the MTU of the link layer data.
         * @param interface The name of the link layer interface.
         * @param data The data pointer from the link layer interface.
         * @return Returns The MTU of the interface or -1 if there's no MTU.
         */
        virtual int get_link_mtu(std::string const& interface, void* data) const;
    };

}}}  // namespace cfacter::facts::linux

#endif  // LIB_INC_FACTS_LINUX_NETWORKING_RESOLVER_HPP_
