/**
 * @file
 * Declares the SOLARIS networking fact resolver.
 */
#pragma once

#include "../posix/networking_resolver.hpp"
#include "../map_value.hpp"
#include <vector>
#include <map>
#include <string>
#include <net/if.h>

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving networking facts.
     */
    struct networking_resolver : posix::networking_resolver
    {
     protected:
        /**
         * Called to resolve interface facts.
         * @param facts The fact collection that is resolving facts.
         */
        virtual void resolve_interface_facts(collection& facts);

        /**
         * Resolve macaddresses of the interfaces, and cache them. This needs to be
         * run before other resolution takes place.
         * @param facts The fact collection that is resolving facts.
         * @param addr The socket address
         * @param primary Whether the interface is primary or not
         */
        virtual void resolve_links(collection& facts, lifreq const* addr, bool primary);

        /**
         * Resolves the address fact for the given interface.
         * @param facts The facts map to add the fact to.
         * @param addr The interface address.
         * @param primary True if the interface is considered to be the primary interface or false if not.
         */
        virtual void resolve_address(collection& facts, lifreq const* addr, bool primary);

        /**
         * Resolves the network fact for the given interface.
         * @param facts The facts map to add the fact to.
         * @param addr The interface address.
         * @param primary True if the interface is considered to be the primary interface or false if not.
         */
        virtual void resolve_network(collection& facts, lifreq const* addr, bool primary);

        /**
         * Resolves the MTU fact for the given interface.
         * @param facts The facts map to add the fact to.
         * @param addr The interface address.
         */
        virtual void resolve_mtu(collection& facts, lifreq const* addr);

        /**
         * Gets the primary interface.
         * This is typically the interface of the default route.
         * @return Returns the primary interface or empty string if one could not be determined.
         */
        virtual std::string get_primary_interface();

        /**
         * Finds the DHCP server for the given interface.
         * @param interface The interface to find the DHCP server for.
         * @returns Returns the DHCP server for the interface or empty string if one isn't found.
         */
        virtual std::string find_dhcp_server(std::string const& interface);

        /**
         * Determines if the given sock address is a link layer address.
         * @param addr The socket address to check.
         * @returns Returns true if the socket address is a link layer address or false if it is not.
         */
        virtual bool is_link_address(const sockaddr* addr) const;

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

     private:
        /**
         * Caches the mapping between socket addresses and macaddresses so that
         * repeated calls are efficient.
         */
        std::multimap<const sockaddr*, uint8_t*> address_map;
    };

}}}  // namespace facter::facts::solaris
