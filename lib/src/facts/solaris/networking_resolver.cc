#include <internal/facts/solaris/networking_resolver.hpp>
#include <internal/util/posix/scoped_descriptor.hpp>
#include <facter/util/string.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <sys/sockio.h>
#include <net/if_arp.h>

using namespace std;
using namespace facter::util::posix;
using namespace facter::util;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace solaris {

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        auto data = posix::networking_resolver::collect_data(facts);

        scoped_descriptor ctl(socket(AF_INET, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed {1} ({2}): interface information is unavailable.", strerror(errno), errno);
            return data;
        }

        // (patterned on bsd impl)
        lifnum ifnr{AF_UNSPEC, 0, 0};
        if (ioctl(ctl, SIOCGLIFNUM, &ifnr) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFNUM failed: {1} ({2}): interface information is unavailable.", strerror(errno), errno);
            return data;
        }

        vector<lifreq> buffer(ifnr.lifn_count);
        lifconf lifc = {AF_UNSPEC, 0, static_cast<int>(buffer.size() * sizeof(lifreq)), reinterpret_cast<caddr_t>(buffer.data())};
        if (ioctl(ctl, SIOCGLIFCONF, &lifc) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFCONF failed: {1} ({2}): interface information is unavailable.", strerror(errno), errno);
            return data;
        }

        // put them in a multimap so that similar address can be
        // grouped together.
        multimap<string, const lifreq*> interface_map;
        for (lifreq const& lreq : buffer) {
            interface_map.insert({lreq.lifr_name, &lreq});
        }

        data.primary_interface = get_primary_interface();

        // Walk the interfaces
        decltype(interface_map.begin()) it = interface_map.begin();
        while (it != interface_map.end()) {
            string const& name = it->first;

            interface iface;
            iface.name = name;

            // Populate the MAC address and MTU once per interface
            populate_macaddress(iface, it->second);
            populate_mtu(iface, it->second);

            // Walk the addresses for this interface
            do {
                populate_binding(iface, it->second);
                ++it;
            } while (it != interface_map.end() && it->first == name);

            // Find the DCHP server for the interface
            iface.dhcp_server = find_dhcp_server(name);

            data.interfaces.emplace_back(move(iface));
        }
        return data;
    }

    void networking_resolver::populate_binding(interface& iface, lifreq const* addr) const
    {
        // Populate the correct bindings list
        vector<binding>* bindings = nullptr;
        if (addr->lifr_addr.ss_family == AF_INET) {
            bindings = &iface.ipv4_bindings;
        } else if (addr->lifr_addr.ss_family == AF_INET) {
            bindings = &iface.ipv6_bindings;
        }

        if (!bindings) {
            return;
        }

        // Create a binding
        binding b;
        b.address = address_to_string(reinterpret_cast<sockaddr const*>(&addr->lifr_addr));

        // Get the netmask
        scoped_descriptor ctl(socket(addr->lifr_addr.ss_family, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed: {1} ({2}): netmask and network for interface {3} are unavailable.", strerror(errno), errno, addr->lifr_name);
        } else {
            lifreq netmask_addr = *addr;
            if (ioctl(ctl, SIOCGLIFNETMASK, &netmask_addr) == -1) {
                LOG_DEBUG("ioctl with SIOCGLIFNETMASK failed: {1} ({2}): netmask and network for interface {3} are unavailable.", strerror(errno), errno, addr->lifr_name);
            } else {
                b.netmask = address_to_string(reinterpret_cast<sockaddr const*>(&netmask_addr.lifr_addr));
                b.network = address_to_string(reinterpret_cast<sockaddr const*>(&addr->lifr_addr), reinterpret_cast<sockaddr const*>(&netmask_addr.lifr_addr));
            }
        }

        bindings->emplace_back(std::move(b));
    }

    void networking_resolver::populate_macaddress(interface& iface, lifreq const* addr) const
    {
        scoped_descriptor ctl(socket(addr->lifr_addr.ss_family, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed: {1} ({2}): link level address for interface {3} is unavailable.", strerror(errno), errno, addr->lifr_name);
            return;
        }

        arpreq arp;
        sockaddr_in* arp_addr = reinterpret_cast<sockaddr_in*>(&arp.arp_pa);
        arp_addr->sin_addr.s_addr = reinterpret_cast<sockaddr_in const*>(&addr->lifr_addr)->sin_addr.s_addr;
        if (ioctl(ctl, SIOCGARP, &arp) == -1) {
            LOG_DEBUG("ioctl with SIOCGARP failed: {1} ({2}): link level address for {3} is unavailable.", strerror(errno), errno, addr->lifr_name);
            return;
        }

        iface.macaddress = macaddress_to_string(reinterpret_cast<uint8_t const*>(arp.arp_ha.sa_data));
    }

    void networking_resolver::populate_mtu(interface& iface, lifreq const* addr) const
    {
        scoped_descriptor ctl(socket(addr->lifr_addr.ss_family, SOCK_DGRAM, 0));
        if (static_cast<int>(ctl) == -1) {
            LOG_DEBUG("socket failed: {1} ({2}): MTU for interface {3} is unavailable.", strerror(errno), errno, addr->lifr_name);
            return;
        }

        lifreq mtu = *addr;
        if (ioctl(ctl, SIOCGLIFMTU, &mtu) == -1) {
            LOG_DEBUG("ioctl with SIOCGLIFMTU failed: {1} ({2}): MTU for interface {3} is unavailable.", strerror(errno), errno, addr->lifr_name);
            return;
        }

        iface.mtu = mtu.lifr_metric;
    }

    string networking_resolver::get_primary_interface() const
    {
        string interface;
        each_line("route", { "-n", "get",  "default" }, [&interface](string& line){
            boost::trim(line);
            if (boost::starts_with(line, "interface: ")) {
                interface = line.substr(11);
                boost::trim(interface);
                return false;
            }
            return true;
        });
        LOG_DEBUG("got primary interface: \"{1}\"", interface);
        return interface;
    }

    bool networking_resolver::is_link_address(const sockaddr* addr) const
    {
        // We explicitly populate the MAC address; we don't need address_to_string to support link layer addresses
        return false;
    }

    uint8_t const* networking_resolver::get_link_address_bytes(const sockaddr * addr) const
    {
        return nullptr;
    }

    uint8_t networking_resolver::get_link_address_length(const sockaddr * addr) const
    {
        return 0;
    }

    string networking_resolver::find_dhcp_server(string const& interface) const
    {
        auto exec = execute("dhcpinfo", { "-i", interface, "ServerID" });
        if (!exec.success) {
            return {};
        }
        return exec.output;
    }

}}}  // namespace facter::facts::solaris
