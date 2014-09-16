#include <facter/facts/solaris/networking_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/util/posix/scoped_descriptor.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <sstream>
#include <cstring>
#include <sys/sockio.h>
#include <net/if_arp.h>

using namespace std;
using namespace facter::util::posix;
using namespace facter::util;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("facts.solaris.networking");

namespace facter { namespace facts { namespace solaris {
    void networking_resolver::resolve_interface_facts(collection& facts)
    {
        struct lifnum ifnr{AF_UNSPEC, 0, 0};
        scoped_descriptor ctl(socket(AF_INET, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed %1% (%2%): networking facts are unavailable", strerror(errno), errno);
            return;
        }

        // (patterned on bsd impl)
        if (ioctl(ctl, SIOCGLIFNUM, &ifnr) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFNUM failed: %1% (%2%): networking facts are unavailable", strerror(errno), errno);
            return;
        }
        vector<lifreq> buffer(ifnr.lifn_count);
        struct lifconf lifc = {AF_UNSPEC, 0, static_cast<int>(buffer.size() * sizeof(struct lifreq)),
            reinterpret_cast<caddr_t>(buffer.data())};

        if (ioctl(ctl, SIOCGLIFCONF, &lifc) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFCONF failed: %1% (%2%): networking facts are unavailable", strerror(errno), errno);
            return;
        }

        // put them in a multimap so that similar address can be
        // grouped together.
        multimap<string, const lifreq*> interface_map;
        for (lifreq const& lreq : buffer) {
            interface_map.insert({lreq.lifr_name, &lreq});
        }

        string primary_interface = get_primary_interface();
        if (primary_interface.empty()) {
            LOG_DEBUG("no primary interface found.");
        }

        auto dhcp_servers_value = make_value<map_value>();

        vector<string> interfaces;
        // Walk the interfaces
        decltype(interface_map.begin()) it = interface_map.begin();
        while (it != interface_map.end()) {
            string const& interface = it->first;
            bool primary = interface == primary_interface;

            // Walk the addresses again and resolve facts
            do {
                auto addr = it->second;
                resolve_address(facts, addr, primary);
                resolve_network(facts, addr, primary);
                resolve_mtu(facts, addr);
                ++it;
            } while (it != interface_map.end() && it->first == interface);

            string dhcp_server = find_dhcp_server(interface);
            if (!dhcp_server.empty()) {
                if (primary) {
                    dhcp_servers_value->add("system", make_value<string_value>(dhcp_server));
                }
                dhcp_servers_value->add(string(interface), make_value<string_value>(move(dhcp_server)));
            }

            interfaces.push_back(interface);
        }

        if (LOG_IS_WARNING_ENABLED() && primary_interface.empty()) {
            LOG_WARNING("no primary interface found: facts %1%, %2%, %3%, %4%, %5%, %6%, and %7% are unavailable.",
                    fact::ipaddress, fact::ipaddress6,
                    fact::netmask, fact::netmask6,
                    fact::network, fact::network6,
                    fact::macaddress);
        }

        // Add the DHCP servers fact
        if (!dhcp_servers_value->empty()) {
            facts.add(fact::dhcp_servers, move(dhcp_servers_value));
        }

        if (!interfaces.empty()) {
            facts.add(fact::interfaces, make_value<string_value>(boost::join(interfaces, ",")));
        }
    }

    void networking_resolver::resolve_links(collection& facts, lifreq const* addr, bool primary)
    {
        scoped_descriptor ctl(socket(addr->lifr_addr.ss_family, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed: %1% (%2%): link level address for %3% is unavailable", strerror(errno), errno, addr->lifr_name);
            return;
        }

        arpreq arp;
        struct sockaddr_in *arp_addr = reinterpret_cast<struct sockaddr_in*>(&arp.arp_pa);
        const struct sockaddr_in *laddr = reinterpret_cast<const struct sockaddr_in*>(&addr->lifr_addr);

        arp_addr->sin_addr.s_addr = laddr->sin_addr.s_addr;

        if (ioctl(ctl, SIOCGARP, &arp) == -1) {
            LOG_DEBUG("ioctl with SIOCGARP failed: %1% (%2%): link level address for %3% is unavailable", strerror(errno), errno, addr->lifr_name);
            return;
        }

        unsigned char* bytes = reinterpret_cast<unsigned char*>(arp.arp_ha.sa_data);
        address_map.insert({reinterpret_cast<const sockaddr*>(&addr->lifr_addr), bytes});

        string address = macaddress_to_string(bytes);
        string factname = fact::macaddress;
        string interface_factname = factname + "_" + addr->lifr_name;

        if (primary) {
            facts.add(move(factname), make_value<string_value>(address));
        }
        facts.add(move(interface_factname), make_value<string_value>(move(address)));
    }

    void networking_resolver::resolve_address(collection& facts, lifreq const* addr, bool primary)
    {
        if (addr->lifr_addr.ss_family == AF_INET) {
            resolve_links(facts, addr, primary);
        }

        string factname = addr->lifr_addr.ss_family == AF_INET ? fact::ipaddress : fact::ipaddress6;
        string address = address_to_string((const sockaddr*)&addr->lifr_addr);

        string interface_factname = factname + "_" + addr->lifr_name;

        if (address.empty()) {
            return;
        }

        if (primary) {
            facts.add(move(factname), make_value<string_value>(address));
        }

        facts.add(move(interface_factname), make_value<string_value>(move(address)));
    }

    void networking_resolver::resolve_network(collection& facts, lifreq const* addr, bool primary)
    {
        scoped_descriptor ctl(socket(addr->lifr_addr.ss_family, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed: %1% (%2%): netmask and network for interface %3% are unavailable", strerror(errno), errno, addr->lifr_name);
            return;
        }

        if (ioctl(ctl, SIOCGLIFNETMASK, addr) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFNETMASK failed: %1% (%2%): netmask and network for interface %3% are unavailable", strerror(errno), errno, addr->lifr_name);
            return;
        }
        // Set the netmask fact
        string factname = addr->lifr_addr.ss_family == AF_INET ? fact::netmask : fact::netmask6;
        string netmask = address_to_string((const struct sockaddr*) &addr->lifr_addr);

        string interface_factname = factname + "_" + addr->lifr_name;

        if (primary) {
            facts.add(move(factname), make_value<string_value>(netmask));
        }

        facts.add(move(interface_factname), make_value<string_value>(move(netmask)));

        // Set the network fact
        factname = addr->lifr_addr.ss_family == AF_INET ? fact::network : fact::network6;
        string network = address_to_string((const struct sockaddr*)&addr->lifr_addr, (const struct sockaddr*)&addr->lifr_broadaddr);
        interface_factname = factname + "_" + addr->lifr_name;

        if (primary) {
            facts.add(move(factname), make_value<string_value>(network));
        }

        facts.add(move(interface_factname), make_value<string_value>(move(network)));
    }

    void networking_resolver::resolve_mtu(collection& facts, lifreq const* addr)
    {
        scoped_descriptor ctl(socket(addr->lifr_addr.ss_family, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed: %1% (%2%): MTU for interface %3% is unavailable", strerror(errno), errno, addr->lifr_name);
            return;
        }

        if (ioctl(ctl, SIOCGLIFMTU, addr) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFMTU failed: %1% (%2%): MTU for interface %3% is unavailable", strerror(errno), errno, addr->lifr_name);
            return;
        }

        int mtu = get_link_mtu(string(addr->lifr_name), const_cast<lifreq*>(addr));
        if (mtu == -1) {
            return;
        }
        facts.add(string(fact::mtu) + '_' + addr->lifr_name, make_value<string_value>(move(to_string(mtu))));
    }

    string networking_resolver::get_primary_interface()
    {
        string value;
        execution::each_line("netstat", { "-rn"}, [&value](string& line) {
            boost::trim(line);
            if (boost::starts_with(line, "default")) {
                vector<string> fields;
                boost::split(fields, line, boost::is_space(), boost::token_compress_on);
                value = fields.size() < 6 ? "" : fields[5];
                return false;
            }
            return true;
        });
        return value;
    }

    bool networking_resolver::is_link_address(const sockaddr* addr) const
    {
        return address_map.count(addr);
    }

    uint8_t const* networking_resolver::get_link_address_bytes(const sockaddr * addr) const
    {
        auto ibytes = address_map.find(addr);
        if (ibytes != address_map.end()) {
            return ibytes->second;
        } else {
            return nullptr;
        }
    }

    int networking_resolver::get_link_mtu(std::string const& interface, void* data) const
    {
        return reinterpret_cast<lifreq*>(data)->lifr_metric;
    }

    string networking_resolver::find_dhcp_server(string const& interface)
    {
        auto result = execute("dhcpinfo", { "-i", interface, "ServerID" });
        if (!result.first) {
            return {};
        }
        return result.second;
    }

}}}  // namespace facter::facts::solaris
