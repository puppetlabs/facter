#include <facter/facts/bsd/networking_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/file.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/string.hpp>
#include <facter/util/bsd/scoped_ifaddrs.hpp>
#include <facter/logging/logging.hpp>
#include <sstream>
#include <cstring>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::bsd;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("facts.bsd.networking");

namespace facter { namespace facts { namespace bsd {

    vector<string> networking_resolver::_dhclient_search_directories = {
        "/var/lib/dhclient",
        "/var/lib/dhcp",
        "/var/lib/dhcp3",
        "/var/lib/NetworkManager",
        "/var/db"
    };

    void networking_resolver::resolve_interface_facts(collection& facts)
    {
        // Scope the head ifaddrs ptr
        scoped_ifaddrs addrs;
        if (!addrs) {
            LOG_WARNING("getifaddrs failed: %1% (%2%): interface facts are unavailable.", strerror(errno), errno);
            return;
        }

        // Map an interface to entries describing that interface
        multimap<string, ifaddrs const*> interface_map;
        for (ifaddrs* ptr = addrs; ptr; ptr = ptr->ifa_next) {
            // We only support IPv4, IPv6, and link interfaces
            if (!ptr->ifa_addr || !ptr->ifa_name ||
                (ptr->ifa_addr->sa_family != AF_INET &&
                 ptr->ifa_addr->sa_family != AF_INET6 &&
                 !is_link_address(ptr->ifa_addr))) {
                continue;
            }

            interface_map.insert({ ptr->ifa_name, ptr });
        }

        ostringstream interfaces;

        string primary_interface = get_primary_interface();
        if (LOG_IS_DEBUG_ENABLED() && primary_interface.empty()) {
            LOG_DEBUG("No primary interface found: using first interface with an assigned address.");
        }

        // Start by getting the DHCP servers
        auto dhcp_servers_value = make_value<map_value>();
        auto dhcp_servers = find_dhcp_servers();

        // Walk the interfaces
        decltype(interface_map.begin()) addr_it;
        for (auto it = interface_map.begin(); it != interface_map.end(); it = addr_it) {
            string const& interface = it->first;
            bool primary = interface == primary_interface;

            auto range = interface_map.equal_range(it->first);

            // If we don't have a primary interface yet, walk the addresses
            // If there's a non-loopback address assigned, treat it as primary
            if (primary_interface.empty()) {
                for (addr_it = range.first; addr_it != range.second; ++addr_it) {
                    ifaddrs const* addr = addr_it->second;
                    if (addr->ifa_addr->sa_family != AF_INET &&
                        addr->ifa_addr->sa_family != AF_INET6) {
                        continue;
                    }

                    string ip = address_to_string(addr->ifa_addr, addr->ifa_netmask);
                    if (!starts_with(ip, "127.") && ip != "::1") {
                        primary_interface = interface;
                        primary = true;
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

            // Populate the interface's DHCP server value
            string dhcp_server;
            auto dhcp_server_it = dhcp_servers.find(interface);
            if (dhcp_server_it == dhcp_servers.end()) {
                dhcp_server = find_dhcp_server(interface);
            } else {
                dhcp_server = move(dhcp_server_it->second);
            }
            if (!dhcp_server.empty()) {
                if (primary) {
                    dhcp_servers_value->add("system", make_value<string_value>(dhcp_server));
                }
                dhcp_servers_value->add(string(interface), make_value<string_value>(move(dhcp_server)));
            }

            // Add the interface to the interfaces fact
            if (interfaces.tellp() != 0) {
                interfaces << ",";
            }

            interfaces << interface;
        }

        if (LOG_IS_WARNING_ENABLED() && primary_interface.empty()) {
            LOG_WARNING("No primary interface found: facts %1%, %2%, %3%, %4%, %5%, %6%, and %7% are unavailable.",
                        fact::ipaddress, fact::ipaddress6,
                        fact::netmask, fact::netmask6,
                        fact::network, fact::network6,
                        fact::macaddress);
        }

        // Add the DHCP servers fact
        if (!dhcp_servers_value->empty()) {
            facts.add(fact::dhcp_servers, move(dhcp_servers_value));
        }

        string value = interfaces.str();
        if (value.empty()) {
            return;
        }
        facts.add(fact::interfaces, make_value<string_value>(move(value)));
    }

    void networking_resolver::resolve_address(collection& facts, ifaddrs const* addr, bool primary)
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

        if (primary) {
            facts.add(move(factname), make_value<string_value>(address));
        }

        facts.add(move(interface_factname), make_value<string_value>(move(address)));
    }

    void networking_resolver::resolve_network(collection& facts, ifaddrs const* addr, bool primary)
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

        if (primary) {
            facts.add(move(factname), make_value<string_value>(netmask));
        }

        facts.add(move(interface_factname), make_value<string_value>(move(netmask)));

        // Set the network fact
        factname = addr->ifa_addr->sa_family == AF_INET ? fact::network : fact::network6;
        string network = address_to_string(addr->ifa_addr, addr->ifa_netmask);
        interface_factname = factname + "_" + addr->ifa_name;

        if (primary) {
            facts.add(move(factname), make_value<string_value>(network));
        }

        facts.add(move(interface_factname), make_value<string_value>(move(network)));
    }

    void networking_resolver::resolve_mtu(collection& facts, ifaddrs const* addr)
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

    string networking_resolver::get_primary_interface()
    {
        // By default, use the fallback logic of looking for the first interface
        // that has a non-loopback address
        return {};
    }

    map<string, string> networking_resolver::find_dhcp_servers()
    {
        map<string, string> servers;

        for (auto const& dir : _dhclient_search_directories) {
            LOG_DEBUG("Searching \"%1%\" for dhclient lease files.", dir);
            directory::each_file(dir, [&](string const& path) {
                LOG_DEBUG("Reading \"%1%\" for dhclient lease information.", path);

                // Each lease entry should have the interface declaration before the options
                // We respect the last lease for an interface in the file
                string interface;
                file::each_line(path, [&](string& line) {
                    line = trim(line);
                    if (starts_with(line, "interface \"")) {
                        interface = rtrim(line.substr(11), { '\"', ';' });
                    } else if (!interface.empty() && starts_with(line, "option dhcp-server-identifier ")) {
                        servers.emplace(make_pair(move(interface), rtrim(line.substr(30), { ';' })));
                    }
                    return true;
                });
                return true;
            }, "^dhclient.*lease.*$");
        }
        return servers;
    }

    string networking_resolver::find_dhcp_server(string const& interface)
    {
        // Use dhcpcd if it's present to get the interface's DHCP lease information
        // This assumes we've already searched for the interface with dhclient
        string value;
        execution::each_line("dhcpcd", { "-U", interface }, [&value](string& line) {
            if (starts_with(line, "dhcp_server_identifier=")) {
                value = trim(line.substr(23));
                return false;
            }
            return true;
        });
        return value;
    }

}}}  // namespace facter::facts::bsd
