#include <facter/util/string.hpp>
#include <internal/facts/bsd/networking_resolver.hpp>
#include <internal/util/bsd/scoped_ifaddrs.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <netinet/in.h>
#include <unordered_map>

using namespace std;
using namespace facter::util::bsd;
using namespace leatherman::execution;
using namespace leatherman::util;
using facter::util::maybe_stoi;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace bsd {

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        auto data = posix::networking_resolver::collect_data(facts);

        // Scope the head ifaddrs ptr
        scoped_ifaddrs addrs;
        if (!addrs) {
            LOG_WARNING("getifaddrs failed: {1} ({2}): interface information is unavailable.", strerror(errno), errno);
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

        // Start by getting the DHCP servers
        auto dhcp_servers = find_dhcp_servers();

        // Walk the interfaces
        decltype(interface_map.begin()) it = interface_map.begin();
        while (it != interface_map.end()) {
            string const& name = it->first;

            interface iface;
            iface.name = name;

            // Walk the addresses of this interface and populate the data
            for (; it != interface_map.end() && it->first == name; ++it) {
                populate_binding(iface, it->second);
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

    void networking_resolver::populate_binding(interface& iface, ifaddrs const* addr) const
    {
        // If the address is a link address, populate the MAC
        if (is_link_address(addr->ifa_addr)) {
            iface.macaddress = address_to_string(addr->ifa_addr);
            return;
        }

        // Populate the correct bindings list
        vector<binding>* bindings = nullptr;
        if (addr->ifa_addr->sa_family == AF_INET) {
            bindings = &iface.ipv4_bindings;
        } else if (addr->ifa_addr->sa_family == AF_INET6) {
            bindings = &iface.ipv6_bindings;
        }

        if (!bindings) {
            return;
        }

        binding b;
        b.address = address_to_string(addr->ifa_addr);
        if (addr->ifa_netmask) {
            b.netmask = address_to_string(addr->ifa_netmask);
            b.network = address_to_string(addr->ifa_addr, addr->ifa_netmask);
        }
        bindings->emplace_back(std::move(b));
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
    void networking_resolver::find_dhclient_dhcp_servers(std::map<std::string, std::string>& servers) const
    {
        static vector<string> const dhclient_search_directories = {
            "/var/lib/dhclient",
            "/var/lib/dhcp",
            "/var/lib/dhcp3",
            "/var/lib/NetworkManager",
            "/var/db"
        };

        for (auto const& dir : dhclient_search_directories) {
            LOG_DEBUG("searching \"{1}\" for dhclient lease files.", dir);
            lth_file::each_file(dir, [&](string const& path) {
                LOG_DEBUG("reading \"{1}\" for dhclient lease information.", path);

                // Each lease entry should have the interface declaration before the options
                // We respect the last lease for an interface in the file
                string interface;
                lth_file::each_line(path, [&](string& line) {
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
    }

    void networking_resolver::find_networkd_dhcp_servers(std::map<std::string, std::string>& servers) const
    {
        // Files in this lease directory are not part of systemd's public API,
        // and they include warnings against parsing them, but they seem to be
        // the only way to get this information for now.
        // Each file is named after the interface's index number.
        static const string networkd_lease_directory = "/run/systemd/netif/leases/";

        if (!boost::filesystem::is_directory(networkd_lease_directory)) return;

        static boost::regex ip_link_re("^(\\d+):\\s+([^:]+)");
        unordered_map<int, string> iface_index_names;
        string key, value;

        // Gather a map of interface indices and their interface names from `ip link show` --
        // Only the index is known in the lease files.
        each_line("ip", {"link", "show"}, [&](string line) {
            if (re_search(line, ip_link_re, &key, &value)) {
                iface_index_names.insert(make_pair(stoi(key), value));
            }
            return true;
        });

        LOG_DEBUG("searching \"{1}\" for systemd-networkd DHCP lease files", networkd_lease_directory);

        lth_file::each_file(networkd_lease_directory, [&](string const& path) {
            LOG_DEBUG("searching \"{1}\" for systemd-networkd DHCP lease information", path);
            string server_address;

            static boost::regex server_address_re("^SERVER_ADDRESS=(.*)$");
            lth_file::each_line(path, [&](string& line) {
                boost::trim(line);
                if (re_search(line, server_address_re, &server_address)) {
                    boost::filesystem::path p {path};
                    auto iface_index = maybe_stoi(p.filename().string());
                    if (!iface_index) return true;
                    servers.emplace(make_pair(iface_index_names[iface_index.get()], server_address));
                }
                return true;
            });
            return true;
        });
    }

    map<string, string> networking_resolver::find_dhcp_servers() const
    {
        map<string, string> servers;

        find_networkd_dhcp_servers(servers);
        if (servers.empty()) find_dhclient_dhcp_servers(servers);

        return servers;
    }

    string networking_resolver::find_dhcp_server(string const& interface) const
    {
        // Use dhcpcd if it's present to get the interface's DHCP lease information
        // This assumes we've already searched for the interface with dhclient
        string value;
        each_line("dhcpcd", { "-U", interface }, [&value](string& line) {
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
