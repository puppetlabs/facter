/**
 * @file
 * Declares the BSD networking fact resolver.
 */
#ifndef FACTER_FACTS_BSD_NETWORKING_RESOLVER_HPP_
#define FACTER_FACTS_BSD_NETWORKING_RESOLVER_HPP_

#include "../posix/networking_resolver.hpp"
#include "../map_value.hpp"
#include <ifaddrs.h>
#include <vector>
#include <map>
#include <string>

namespace facter { namespace facts { namespace bsd {

    /**
     * Responsible for resolving networking facts.
     */
    struct networking_resolver : posix::networking_resolver
    {
     protected:
        /**
         * Called to resolve interface facts.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_interface_facts(fact_map& facts);

        /**
         * Resolves the address fact for the given interface.
         * @param facts The facts map to add the fact to.
         * @param addr The interface address.
         * @param primary True if the interface is considered to be the primary interface or false if not.
         */
        virtual void resolve_address(fact_map& facts, ifaddrs const* addr, bool primary);

        /**
         * Resolves the network fact for the given interface.
         * @param facts The facts map to add the fact to.
         * @param addr The interface address.
         * @param primary True if the interface is considered to be the primary interface or false if not.
         */
        virtual void resolve_network(fact_map& facts, ifaddrs const* addr, bool primary);

        /**
         * Resolves the MTU fact for the given interface.
         * @param facts The facts map to add the fact to.
         * @param addr The interface address.
         */
        virtual void resolve_mtu(fact_map& facts, ifaddrs const* addr);

        /**
         * Gets the primary interface.
         * This is typically the interface of the default route.
         * @return Returns the primary interface or empty string if one could not be determined.
         */
        virtual std::string get_primary_interface();

        /**
         * Finds known DHCP servers for all interfaces.
         * @return Returns a map between interface name and DHCP server.
         */
        virtual std::map<std::string, std::string> find_dhcp_servers();

        /**
         * Finds the DHCP server for the given interface.
         * @param interface The interface to find the DHCP server for.
         * @returns Returns the DHCP server for the interface or empty string if one isn't found.
         */
        virtual std::string find_dhcp_server(std::string const& interface);

     private:
        static std::vector<std::string> _dhclient_search_directories;
    };

}}}  // namespace facter::facts::bsd

#endif  // FACTER_FACTS_BSD_NETWORKING_RESOLVER_HPP_
