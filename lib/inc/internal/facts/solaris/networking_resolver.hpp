/**
 * @file
 * Declares the Solaris networking fact resolver.
 */
#pragma once

#include "../posix/networking_resolver.hpp"
#include <map>
#include <net/if.h>

namespace facter { namespace facts { namespace solaris {

    /**
     * Responsible for resolving networking facts.
     */
    struct networking_resolver : posix::networking_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

        /**
        * Determines if the given sock address is a link layer address.
        * @param addr The socket address to check.
        * @returns Returns true if the socket address is a link layer address or false if it is not.
        */
        virtual bool is_link_address(sockaddr const* addr) const override;

        /**
        * Gets the bytes of the link address.
        * @param addr The socket address representing the link address.
        * @return Returns a pointer to the address bytes or nullptr if not a link address.
        */
        virtual uint8_t const* get_link_address_bytes(sockaddr const* addr) const override;

     private:
        void populate_binding(interface& iface, lifreq const* addr) const;
        void populate_macaddress(interface& iface, lifreq const* addr) const;
        void populate_mtu(interface& iface, lifreq const* addr) const;
        std::string find_dhcp_server(std::string const& interface) const;
        std::string get_primary_interface() const;
    };

}}}  // namespace facter::facts::solaris
