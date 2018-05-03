/**
 * @file
 * Declares the BSD networking fact resolver.
 */
#pragma once

#include "../posix/networking_resolver.hpp"
#include <map>
#include <ifaddrs.h>

namespace facter { namespace facts { namespace bsd {

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
         * Gets the MTU of the link layer data.
         * @param interface The name of the link layer interface.
         * @param data The data pointer from the link layer interface.
         * @return Returns The MTU of the interface.
         */
        virtual boost::optional<uint64_t> get_link_mtu(std::string const& interface, void* data) const = 0;

        /**
         * Gets the primary interface.
         * This is typically the interface of the default route.
         * @return Returns the primary interface or empty string if one could not be determined.
         */
        virtual std::string get_primary_interface() const;

        /**
         * Finds known DHCP servers for all interfaces.
         * @return Returns a map between interface name and DHCP server.
         */
        virtual std::map<std::string, std::string> find_dhcp_servers() const;

        /**
         * Finds the DHCP server for the given interface.
         * @param interface The interface to find the DHCP server for.
         * @returns Returns the DHCP server for the interface or empty string if one isn't found.
         */
        virtual std::string find_dhcp_server(std::string const& interface) const;

     private:
        void find_dhclient_dhcp_servers(std::map<std::string, std::string>& servers) const;
        void find_networkd_dhcp_servers(std::map<std::string, std::string>& servers) const;
        void populate_binding(interface& iface, ifaddrs const* addr) const;
        void populate_mtu(interface& iface, ifaddrs const* addr) const;
    };

}}}  // namespace facter::facts::bsd
