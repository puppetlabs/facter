#include <facter/facts/resolvers/networking_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <boost/format.hpp>
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

    void networking_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        // If no FQDN, set it to the hostname + domain
        if (!data.hostname.empty() && data.fqdn.empty()) {
            data.fqdn = data.hostname + (data.domain.empty() ? "" : ".") + data.domain;
        }

        auto networking = make_value<map_value>();

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

        ostringstream interface_names;
        auto dhcp_servers = make_value<map_value>(true);
        auto interfaces = make_value<map_value>();
        for (auto& interface : data.interfaces) {
            bool primary = interface.name == data.primary_interface;
            auto value = make_value<map_value>();
            if (!interface.address.v4.empty()) {
                facts.add(string(fact::ipaddress) + "_" + interface.name, make_value<string_value>(interface.address.v4, true));
                if (primary) {
                    facts.add(fact::ipaddress, make_value<string_value>(interface.address.v4, true));
                    networking->add("ip", make_value<string_value>(interface.address.v4));
                }
                value->add("ip", make_value<string_value>(move(interface.address.v4)));
            }
            if (!interface.address.v6.empty()) {
                facts.add(string(fact::ipaddress6) + "_" + interface.name, make_value<string_value>(interface.address.v6, true));
                if (primary) {
                    facts.add(fact::ipaddress6, make_value<string_value>(interface.address.v6, true));
                    networking->add("ip6", make_value<string_value>(interface.address.v6));
                }
                value->add("ip6", make_value<string_value>(move(interface.address.v6)));
            }
            if (!interface.netmask.v4.empty()) {
                facts.add(string(fact::netmask) + "_" + interface.name, make_value<string_value>(interface.netmask.v4, true));
                if (primary) {
                    facts.add(fact::netmask, make_value<string_value>(interface.netmask.v4, true));
                    networking->add("netmask", make_value<string_value>(interface.netmask.v4));
                }
                value->add("netmask", make_value<string_value>(move(interface.netmask.v4)));
            }
            if (!interface.netmask.v6.empty()) {
                facts.add(string(fact::netmask6) + "_" + interface.name, make_value<string_value>(interface.netmask.v6, true));
                if (primary) {
                    facts.add(fact::netmask6, make_value<string_value>(interface.netmask.v6, true));
                    networking->add("netmask6", make_value<string_value>(interface.netmask.v6));
                }
                value->add("netmask6", make_value<string_value>(move(interface.netmask.v6)));
            }
            if (!interface.network.v4.empty()) {
                facts.add(string(fact::network) + "_" + interface.name, make_value<string_value>(interface.network.v4, true));
                if (primary) {
                    facts.add(fact::network, make_value<string_value>(interface.network.v4, true));
                    networking->add("network", make_value<string_value>(interface.network.v4));
                }
                value->add("network", make_value<string_value>(move(interface.network.v4)));
            }
            if (!interface.network.v6.empty()) {
                facts.add(string(fact::network6) + "_" + interface.name, make_value<string_value>(interface.network.v6, true));
                if (primary) {
                    facts.add(fact::network6, make_value<string_value>(interface.network.v6, true));
                    networking->add("network6", make_value<string_value>(interface.network.v6));
                }
                value->add("network6", make_value<string_value>(move(interface.network.v6)));
            }
            if (!interface.macaddress.empty()) {
                facts.add(string(fact::macaddress) + "_" + interface.name, make_value<string_value>(interface.macaddress, true));
                if (primary) {
                    facts.add(fact::macaddress, make_value<string_value>(interface.macaddress, true));
                    networking->add("mac", make_value<string_value>(interface.macaddress));
                }
                value->add("mac", make_value<string_value>(move(interface.macaddress)));
            }
            if (!interface.dhcp_server.empty()) {
                if (primary) {
                    dhcp_servers->add("system", make_value<string_value>(interface.dhcp_server));
                    networking->add("dhcp", make_value<string_value>(interface.dhcp_server));
                }
                dhcp_servers->add(string(interface.name), make_value<string_value>(interface.dhcp_server));
                value->add("dhcp", make_value<string_value>(move(interface.dhcp_server)));
            }
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

}}}  // namespace facter::facts::posix
