#include <internal/facts/resolvers/networking_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/format.hpp>
#include <boost/algorithm/string.hpp>
#include <sstream>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    networking_resolver::networking_resolver() :
        resolver(
            "networking",
            {
                fact::networking,
                fact::hostname,
                fact::ipaddress,
                fact::ipaddress6,
                fact::netmask,
                fact::netmask6,
                fact::network,
                fact::network6,
                fact::macaddress,
                fact::interfaces,
                fact::domain,
                fact::fqdn,
                fact::dhcp_servers,
            },
            {
                string("^") + fact::ipaddress + "_",
                string("^") + fact::ipaddress6 + "_",
                string("^") + fact::mtu + "_",
                string("^") + fact::netmask + "_",
                string("^") + fact::netmask6 + "_",
                string("^") + fact::network + "_",
                string("^") + fact::network6 + "_",
                string("^") + fact::macaddress + "_",
            })
    {
    }

    void networking_resolver::resolve(collection& facts, set<string> const& blocklist)
    {
        auto data = collect_data(facts);

        // Some queries, such as /etc/resolv.conf, can return domains with a trailing dot (.).
        // We want to strip the trailing dot, as it is not useful as a valid domain or fqdn.
        boost::trim_right_if(data.domain, boost::is_any_of("."));

        // If no FQDN, set it to the hostname + domain
        if (!data.hostname.empty() && data.fqdn.empty()) {
            data.fqdn = data.hostname + (data.domain.empty() ? "" : ".") + data.domain;
        }

        // If no primary interface was found, default to the first interface with a valid address
        if (data.primary_interface.empty()) {
            LOG_DEBUG("no primary interface found: using the first interface with an assigned address as the primary interface.");
            auto primary = find_primary_interface(data.interfaces);
            if (primary) {
                data.primary_interface = primary->name;
            }
        }

        auto networking = make_value<map_value>();

        // Add the interface data
        ostringstream interface_names;
        auto dhcp_servers = make_value<map_value>(true);
        auto interfaces = make_value<map_value>();
        for (auto& interface : data.interfaces) {
            bool primary = interface.name == data.primary_interface;
            auto value = make_value<map_value>();

            // Add the ipv4 bindings
            add_bindings(interface, primary, true, facts, *networking, *value);

            // Add the ipv6 bindings
            add_bindings(interface, primary, false, facts, *networking, *value);

            // Add the MAC address
            if (!interface.macaddress.empty()) {
                facts.add(string(fact::macaddress) + "_" + interface.name, make_value<string_value>(interface.macaddress, true));
                if (primary) {
                    facts.add(fact::macaddress, make_value<string_value>(interface.macaddress, true));
                    networking->add("mac", make_value<string_value>(interface.macaddress));
                }
                value->add("mac", make_value<string_value>(move(interface.macaddress)));
            }
            // Add the DHCP server
            if (!interface.dhcp_server.empty()) {
                if (primary) {
                    dhcp_servers->add("system", make_value<string_value>(interface.dhcp_server));
                    networking->add("dhcp", make_value<string_value>(interface.dhcp_server));
                }
                dhcp_servers->add(string(interface.name), make_value<string_value>(interface.dhcp_server));
                value->add("dhcp", make_value<string_value>(move(interface.dhcp_server)));
            }
            // Add the interface MTU
            if (interface.mtu) {
                facts.add(string(fact::mtu) + "_" + interface.name, make_value<integer_value>(*interface.mtu, true));
                if (primary) {
                    networking->add("mtu", make_value<integer_value>(*interface.mtu));
                }
                value->add("mtu", make_value<integer_value>(*interface.mtu));
            }

            // Add the interface to the list of names
            if (interface_names.tellp() != 0) {
                interface_names << ",";
            }
            interface_names << interface.name;

            interfaces->add(move(interface.name), move(value));
        }

        // Add top-level network data
        if (!data.hostname.empty()) {
            facts.add(fact::hostname, make_value<string_value>(data.hostname, true));
            networking->add("hostname", make_value<string_value>(move(data.hostname)));
        }
        if (!data.domain.empty()) {
            facts.add(fact::domain, make_value<string_value>(data.domain, true));
            networking->add("domain", make_value<string_value>(move(data.domain)));
        }
        if (!data.fqdn.empty()) {
            facts.add(fact::fqdn, make_value<string_value>(data.fqdn, true));
            networking->add("fqdn", make_value<string_value>(move(data.fqdn)));
        }
        if (!data.primary_interface.empty()) {
            networking->add("primary", make_value<string_value>(move(data.primary_interface)));
        }

        if (interface_names.tellp() != 0) {
            facts.add(fact::interfaces, make_value<string_value>(interface_names.str(), true));
        }

        if (!dhcp_servers->empty()) {
            facts.add(fact::dhcp_servers, move(dhcp_servers));
        }

        if (!interfaces->empty()) {
            networking->add("interfaces", move(interfaces));
        }
        if (!networking->empty()) {
            facts.add(fact::networking, move(networking));
        }
    }

    string networking_resolver::macaddress_to_string(uint8_t const* bytes)
    {
        if (!bytes) {
            return {};
        }

        // Ignore MAC address "0"
        bool nonzero = false;
        for (size_t i = 0; i < 6; ++i) {
            if (bytes[i] != 0) {
                nonzero = true;
                break;
            }
        }
        if (!nonzero) {
            return {};
        }

        return (boost::format("%02x:%02x:%02x:%02x:%02x:%02x") %
                static_cast<int>(bytes[0]) % static_cast<int>(bytes[1]) %
                static_cast<int>(bytes[2]) % static_cast<int>(bytes[3]) %
                static_cast<int>(bytes[4]) % static_cast<int>(bytes[5])).str();
    }

    bool networking_resolver::ignored_ipv4_address(string const& addr)
    {
        // Excluding localhost and 169.254.x.x in Windows - this is the DHCP APIPA, meaning that if the node cannot
        // get an ip address from the dhcp server, it auto-assigns a private ip address
        return addr.empty() ||  boost::starts_with(addr, "127.") || boost::starts_with(addr, "169.254.");
    }

    bool networking_resolver::ignored_ipv6_address(string const& addr)
    {
        return addr.empty() || addr == "::1" || boost::starts_with(addr, "fe80");
    }

    networking_resolver::binding const* networking_resolver::find_default_binding(vector<binding> const& bindings, function<bool(string const&)> const& ignored)
    {
        for (auto& binding : bindings) {
            if (!ignored(binding.address)) {
                return &binding;
            }
        }
        return bindings.empty() ? nullptr : &bindings.front();
    }

    void networking_resolver::add_bindings(interface& iface, bool primary, bool ipv4, collection& facts, map_value& networking, map_value& iface_value)
    {
        auto ip_fact = ipv4 ? fact::ipaddress : fact::ipaddress6;
        auto ip_name = ipv4 ? "ip" : "ip6";
        auto netmask_fact = ipv4 ? fact::netmask : fact::netmask6;
        auto netmask_name = ipv4 ? "netmask" : "netmask6";
        auto network_fact = ipv4 ? fact::network : fact::network6;
        auto network_name = ipv4 ? "network" : "network6";
        auto& bindings = ipv4 ? iface.ipv4_bindings : iface.ipv6_bindings;
        auto bindings_name = ipv4 ? "bindings" : "bindings6";
        auto ignored = ipv4 ? &ignored_ipv4_address : &ignored_ipv6_address;

        // Add the default binding to the collection and interface
        auto binding = find_default_binding(bindings, ignored);
        if (binding) {
            if (!binding->address.empty()) {
                facts.add(string(ip_fact) + "_" + iface.name, make_value<string_value>(binding->address, true));
                if (primary) {
                    facts.add(ip_fact, make_value<string_value>(binding->address, true));
                    networking.add(ip_name, make_value<string_value>(binding->address));
                }
                iface_value.add(ip_name, make_value<string_value>(binding->address));
            }
            if (!binding->netmask.empty()) {
                facts.add(string(netmask_fact) + "_" + iface.name, make_value<string_value>(binding->netmask, true));
                if (primary) {
                    facts.add(netmask_fact, make_value<string_value>(binding->netmask, true));
                    networking.add(netmask_name, make_value<string_value>(binding->netmask));
                }
                iface_value.add(netmask_name, make_value<string_value>(binding->netmask));
            }
            if (!binding->network.empty()) {
                facts.add(string(network_fact) + "_" + iface.name, make_value<string_value>(binding->network, true));
                if (primary) {
                    facts.add(network_fact, make_value<string_value>(binding->network, true));
                    networking.add(network_name, make_value<string_value>(binding->network));
                }
                iface_value.add(network_name, make_value<string_value>(binding->network));
            }
        }

        // Set the bindings in the interface
        if (!bindings.empty()) {
            auto bindings_value = make_value<array_value>();
            for (auto& binding : bindings) {
                auto binding_value = make_value<map_value>();
                if (!binding.address.empty()) {
                    binding_value->add("address", make_value<string_value>(move(binding.address)));
                }
                if (!binding.netmask.empty()) {
                    binding_value->add("netmask", make_value<string_value>(move(binding.netmask)));
                }
                if (!binding.network.empty()) {
                    binding_value->add("network", make_value<string_value>(move(binding.network)));
                }
                if (!binding_value->empty()) {
                    bindings_value->add(move(binding_value));
                }
            }
            iface_value.add(bindings_name, move(bindings_value));
        }
    }

    networking_resolver::interface const* networking_resolver::find_primary_interface(vector<interface> const& interfaces)
    {
        for (auto const& interface : interfaces) {
            for (auto const& binding : interface.ipv4_bindings) {
                if (!ignored_ipv4_address(binding.address)) {
                    return &interface;
                }
            }
            for (auto const& binding : interface.ipv6_bindings) {
                if (!ignored_ipv6_address(binding.address)) {
                    return &interface;
                }
            }
        }
        return nullptr;
    }

}}}  // namespace facter::facts::posix
