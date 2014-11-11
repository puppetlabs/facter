#include <facter/facts/bsd/networking_resolver.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/file.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/bsd/scoped_ifaddrs.hpp>
#include <facter/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <netinet/in.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::bsd;
using namespace facter::execution;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.bsd.networking"

namespace facter { namespace facts { namespace bsd {

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        auto data = posix::networking_resolver::collect_data(facts);

        // Scope the head ifaddrs ptr
        scoped_ifaddrs addrs;
        if (!addrs) {
            LOG_WARNING("getifaddrs failed: %1% (%2%): interface information is unavailable.", strerror(errno), errno);
            return data;
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

        data.primary_interface = get_primary_interface();
        if (data.primary_interface.empty()) {
            LOG_DEBUG("no primary interface found: using first interface with an assigned address.");
        }

        // Start by getting the DHCP servers
        auto dhcp_servers = find_dhcp_servers();

        // Walk the interfaces
        decltype(interface_map.begin()) it = interface_map.begin();
        while (it != interface_map.end()) {
            string const& name = it->first;

            // If we don't have a primary interface yet, walk the addresses
            // If there's a non-loopback address assigned, treat it as primary
            if (data.primary_interface.empty()) {
                for (auto addr_it = it; addr_it != interface_map.end() && addr_it->first == name; ++addr_it) {
                    ifaddrs const *addr = addr_it->second;
                    if (addr->ifa_addr->sa_family != AF_INET && addr->ifa_addr->sa_family != AF_INET6) {
                        continue;
                    }

                    string ip = address_to_string(addr->ifa_addr, addr->ifa_netmask);
                    if (!boost::starts_with(ip, "127.") && ip != "::1" && !boost::starts_with(ip, "fe80")) {
                        data.primary_interface = name;
                        break;
                    }
                }
            }

            interface iface;
            iface.name = name;

            // Walk the addresses of this interface and populate the data
            for (; it != interface_map.end() && it->first == name; ++it) {
                populate_address(iface, it->second);
                populate_network(iface, it->second);
                populate_mtu(iface, it->second);
            }

            // Populate the interface's DHCP server value
            auto dhcp_server_it = dhcp_servers.find(name);
            if (dhcp_server_it == dhcp_servers.end()) {
                iface.dhcp_server = find_dhcp_server(name);
            } else {
                iface.dhcp_server = dhcp_server_it->second;
            }

            data.interfaces.emplace_back(move(iface));
        }
        return data;
    }

    void networking_resolver::populate_address(interface& iface, ifaddrs const* addr) const
    {
        string* address = nullptr;
        if (addr->ifa_addr->sa_family == AF_INET) {
            address = &iface.address.v4;
        } else if (addr->ifa_addr->sa_family == AF_INET6) {
            address = &iface.address.v6;
        } else if (is_link_address(addr->ifa_addr)) {
            address = &iface.macaddress;
        }

        if (!address) {
            // Unsupported address
            return;
        }

        *address = address_to_string(addr->ifa_addr);
    }

    void networking_resolver::populate_network(interface& iface, ifaddrs const* addr) const
    {
        // Limit these facts to IPv4 and IPv6 with a netmask address
        if ((addr->ifa_addr->sa_family != AF_INET &&
             addr->ifa_addr->sa_family != AF_INET6) || !addr->ifa_netmask) {
            return;
        }

        if (addr->ifa_addr->sa_family == AF_INET) {
            // Check to see if the data already exists; interfaces can have multiple addresses of the same type
            if (!iface.netmask.v4.empty()) {
                return;
            }
            iface.netmask.v4 = address_to_string(addr->ifa_netmask);
            iface.network.v4 = address_to_string(addr->ifa_addr, addr->ifa_netmask);
        } else {
            // Check to see if the data already exists; interfaces can have multiple addresses of the same type
            if (!iface.netmask.v6.empty()) {
                return;
            }
            iface.netmask.v6 = address_to_string(addr->ifa_netmask);
            iface.network.v6 = address_to_string(addr->ifa_addr, addr->ifa_netmask);
        }
    }

    void networking_resolver::populate_mtu(interface& iface, ifaddrs const* addr) const
    {
        // The MTU exists on link addresses
        if (!is_link_address(addr->ifa_addr) || !addr->ifa_data) {
            return;
        }

        iface.mtu = get_link_mtu(addr->ifa_name, addr->ifa_data);
    }

    string networking_resolver::get_primary_interface() const
    {
        // By default, use the fallback logic of looking for the first interface
        // that has a non-loopback address
        return {};
    }

    map<string, string> networking_resolver::find_dhcp_servers() const
    {
        map<string, string> servers;

        static vector<string> const dhclient_search_directories = {
            "/var/lib/dhclient",
            "/var/lib/dhcp",
            "/var/lib/dhcp3",
            "/var/lib/NetworkManager",
            "/var/db"
        };

        for (auto const& dir : dhclient_search_directories) {
            LOG_DEBUG("searching \"%1%\" for dhclient lease files.", dir);
            directory::each_file(dir, [&](string const& path) {
                LOG_DEBUG("reading \"%1%\" for dhclient lease information.", path);

                // Each lease entry should have the interface declaration before the options
                // We respect the last lease for an interface in the file
                string interface;
                file::each_line(path, [&](string& line) {
                    boost::trim(line);
                    if (boost::starts_with(line, "interface ")) {
                        interface = line.substr(10);
                        trim_if(interface, boost::is_any_of("\";"));
                    } else if (!interface.empty() && boost::starts_with(line, "option dhcp-server-identifier ")) {
                        string server = line.substr(30);
                        trim_if(server, boost::is_any_of("\";"));
                        servers.emplace(make_pair(move(interface), move(server)));
                    }
                    return true;
                });
                return true;
            }, "^dhclient.*lease.*$");
        }
        return servers;
    }

    string networking_resolver::find_dhcp_server(string const& interface) const
    {
        // Use dhcpcd if it's present to get the interface's DHCP lease information
        // This assumes we've already searched for the interface with dhclient
        string value;
        execution::each_line("dhcpcd", { "-U", interface }, [&value](string& line) {
            if (boost::starts_with(line, "dhcp_server_identifier=")) {
                value = line.substr(23);
                boost::trim(value);
                return false;
            }
            return true;
        });
        return value;
    }

}}}  // namespace facter::facts::bsd
