#include <facter/facts/bsd/networking_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/util/string.hpp>
#include <facter/util/bsd/scoped_ifaddrs.hpp>
#include <facter/logging/logging.hpp>
#include <sstream>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::bsd;

LOG_DECLARE_NAMESPACE("facts.bsd.networking");

namespace facter { namespace facts { namespace bsd {

    void networking_resolver::resolve_interface_facts(fact_map& facts)
    {
        // Scope the head ifaddrs ptr
        scoped_ifaddrs addrs;
        if (!addrs) {
            LOG_WARNING("getifaddrs failed with %1%: interface facts are unavailable.", errno);
            return;
        }

        // Map an interface to entries describing that interface
        multimap<string, ifaddrs const*> interface_map;
        for (ifaddrs* ptr = addrs; ptr; ptr = ptr->ifa_next) {
            // We only support IPv4, IPv6, and link interfaces
            if (ptr->ifa_addr->sa_family != AF_INET &&
                ptr->ifa_addr->sa_family != AF_INET6 &&
                !is_link_address(ptr->ifa_addr)) {
                continue;
            }

            interface_map.insert({ ptr->ifa_name, ptr });
        }

        ostringstream interfaces;
        bool found_primary = false;

        // Walk the interfaces
        decltype(interface_map.begin()) addr_it;
        for (auto it = interface_map.begin(); it != interface_map.end(); it = addr_it) {
            string const& interface = it->first;
            bool primary = false;

            auto range = interface_map.equal_range(it->first);

            // Walk the the addresses for the interface to check if it's primary
            if (!found_primary) {
                for (addr_it = range.first; addr_it != range.second; ++addr_it) {
                    ifaddrs const* addr = addr_it->second;
                    if (addr->ifa_addr->sa_family != AF_INET &&
                        addr->ifa_addr->sa_family != AF_INET6) {
                        continue;
                    }

                    string ip = address_to_string(addr->ifa_addr, addr->ifa_netmask);
                    primary = !starts_with(ip, "127.") && ip != "::1";
                    if (primary) {
                        found_primary = true;
                    }
                }
            }

            // Walk the addresses again and resolve facts
            for (addr_it = range.first; addr_it != range.second; ++addr_it) {
                ifaddrs const* addr = addr_it->second;
                resolve_address(facts, addr, primary);
                resolve_network(facts, addr, primary);
                resolve_mtu(facts, addr);
            }

            // Add the interface to the interfaces fact
            if (interfaces.tellp() != 0) {
                interfaces << ",";
            }

            interfaces << interface;
        }

        string value = interfaces.str();
        if (value.empty()) {
            return;
        }
        facts.add(fact::interfaces, make_value<string_value>(move(value)));
    }

    void networking_resolver::resolve_address(fact_map& facts, ifaddrs const* addr, bool primary)
    {
        string factname;

        // The fact name is based on the address type
        if (addr->ifa_addr->sa_family == AF_INET) {
            factname = fact::ipaddress;
        } else if (addr->ifa_addr->sa_family == AF_INET6) {
            factname = fact::ipaddress6;
        } else if (is_link_address(addr->ifa_addr)) {
            factname = fact::macaddress;
        } else {
            // Unsupported address
            return;
        }

        string address = address_to_string(addr->ifa_addr);
        if (address.empty()) {
            return;
        }

        // Check to see if the fact already exists; interfaces can have multiple addresses of the same type
        string interface_factname = factname + "_" + addr->ifa_name;
        if (facts.get<string_value>(interface_factname, false)) {
            return;
        }

        facts.add(move(interface_factname), make_value<string_value>(address));
        if (primary) {
            facts.add(move(factname), make_value<string_value>(move(address)));
        }
    }

    void networking_resolver::resolve_network(fact_map& facts, ifaddrs const* addr, bool primary)
    {
        // Limit these facts to IPv4 and IPv6 with a netmask address
        if ((addr->ifa_addr->sa_family != AF_INET &&
             addr->ifa_addr->sa_family != AF_INET6) || !addr->ifa_netmask) {
            return;
        }

        // Set the netmask fact
        string factname = addr->ifa_addr->sa_family == AF_INET ? fact::netmask : fact::netmask6;
        string netmask = address_to_string(addr->ifa_netmask);

        // Check to see if the fact already exists; interfaces can have multiple addresses of the same type
        string interface_factname = factname + "_" + addr->ifa_name;
        if (facts.get<string_value>(interface_factname, false)) {
            return;
        }

        facts.add(move(interface_factname), make_value<string_value>(netmask));

        if (primary) {
            facts.add(move(factname), make_value<string_value>(move(netmask)));
        }

        // Set the network fact
        factname = addr->ifa_addr->sa_family == AF_INET ? fact::network : fact::network6;
        string network = address_to_string(addr->ifa_addr, addr->ifa_netmask);
        interface_factname = factname + "_" + addr->ifa_name;
        facts.add(move(interface_factname), make_value<string_value>(network));

        if (primary) {
            facts.add(move(factname), make_value<string_value>(move(network)));
        }
    }

    void networking_resolver::resolve_mtu(fact_map& facts, ifaddrs const* addr)
    {
        // The MTU exists on link addresses
        if (!is_link_address(addr->ifa_addr) || !addr->ifa_data) {
            return;
        }

        int mtu = get_link_mtu(addr->ifa_name, addr->ifa_data);
        if (mtu == -1) {
            return;
        }
        facts.add(string(fact::mtu) + '_' + addr->ifa_name, make_value<string_value>(to_string(mtu)));
    }

}}}  // namespace facter::facts::bsd
