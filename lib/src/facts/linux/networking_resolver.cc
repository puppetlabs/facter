#include <internal/facts/linux/networking_resolver.hpp>
#include <internal/util/posix/scoped_descriptor.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <algorithm>
#include <cstring>
#include <unordered_set>
#include <netpacket/packet.h>
#include <net/if.h>
#include <sys/ioctl.h>

using namespace std;
using namespace facter::util::posix;

namespace lth_file = leatherman::file_util;
namespace lth_exe  = leatherman::execution;

namespace facter { namespace facts { namespace linux {

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        read_routing_table();
        data result = bsd::networking_resolver::collect_data(facts);
        populate_from_routing_table(result);

        // On linux, the macaddress of bonded interfaces is reported
        // as the address of the bonding master. We want to report the
        // original HW address, so we dig it out of /proc
        for (auto& interface : result.interfaces) {
            // For each interface we check if we're part of a bond,
            // and update the `macaddress` fact if we are
            auto bond_master = get_bond_master(interface.name);
            if (!bond_master.empty()) {
                bool in_our_block = false;
                lth_file::each_line("/proc/net/bonding/"+bond_master, [&](string& line) {
                    // /proc/net/bonding files are organized into chunks for each slave
                    // interface. We want to grab the mac address for the block we're in.
                    if (line == "Slave Interface: " + interface.name) {
                        in_our_block = true;
                    } else if (line.find("Slave Interface") != string::npos) {
                        in_our_block = false;
                    }

                    // If we're in the block for our iface, we can grab the HW address
                    if (in_our_block && line.find("Permanent HW addr: ") != string::npos) {
                        auto split = line.find(':') + 2;
                        interface.macaddress = line.substr(split, string::npos);
                        return false;
                    }
                    return true;
                });
            }
        }
        return result;
    }

    bool networking_resolver::is_link_address(sockaddr const* addr) const
    {
        return addr && addr->sa_family == AF_PACKET;
    }

    uint8_t const* networking_resolver::get_link_address_bytes(sockaddr const* addr) const
    {
        if (!is_link_address(addr)) {
            return nullptr;
        }
        sockaddr_ll const* link_addr = reinterpret_cast<sockaddr_ll const*>(addr);
        if (link_addr->sll_halen != 6 && link_addr->sll_halen != 20) {
            return nullptr;
        }
        return reinterpret_cast<uint8_t const*>(link_addr->sll_addr);
    }

    uint8_t networking_resolver::get_link_address_length(sockaddr const* addr) const
    {
        if (!is_link_address(addr)) {
            return 0;
        }
        sockaddr_ll const* link_addr = reinterpret_cast<sockaddr_ll const*>(addr);
        return link_addr->sll_halen;
    }

    boost::optional<uint64_t> networking_resolver::get_link_mtu(string const& interface, void* data) const
    {
        // Unfortunately in Linux, the data points at interface statistics
        // Nothing useful for us, so we need to use ioctl to query the MTU
        ifreq req;
        memset(&req, 0, sizeof(req));
        strncpy(req.ifr_name, interface.c_str(), sizeof(req.ifr_name));

        scoped_descriptor sock(socket(AF_INET, SOCK_DGRAM, 0));
        if (static_cast<int>(sock) < 0) {
            LOG_WARNING("socket failed: {1} ({2}): interface MTU fact is unavailable for interface {3}.", strerror(errno), errno, interface);
            return boost::none;
        }

        if (ioctl(sock, SIOCGIFMTU, &req) == -1) {
            LOG_WARNING("ioctl failed: {1} ({2}): interface MTU fact is unavailable for interface {3}.", strerror(errno), errno, interface);
            return boost::none;
        }
        return req.ifr_mtu;
    }

    string networking_resolver::get_primary_interface() const
    {
        // If we have a list of routes, then we'll determine the
        // primary interface from that later on when we are processing
        // them.
        if (routes4.size()) {
             return {};
        }

        // Read /proc/net/route to determine the primary interface
        // We consider the primary interface to be the one that has 0.0.0.0 as the
        // routing destination.
        string interface;
        lth_file::each_line("/proc/net/route", [&interface](string& line) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_space(), boost::token_compress_on);
            if (parts.size() > 7 && parts[1] == boost::as_literal("00000000")
                                 && parts[7] == boost::as_literal("00000000")) {
                interface.assign(parts[0].begin(), parts[0].end());
                return false;
            }
            return true;
        });
        return interface;
    }

    void networking_resolver::read_routing_table()
    {
        auto ip_command = lth_exe::which("ip");
        if (ip_command.empty()) {
            LOG_DEBUG("Could not find the 'ip' command. Network bindings will not be populated from routing table");
            return;
        }

        unordered_set<string> known_route_types {
            "unicast",
            "broadcast",
            "local",
            "nat",
            "unreachable",
            "prohibit",
            "blackhole",
            "throw"
        };

        auto parse_route_line = [&known_route_types](string& line, int family, std::vector<route>& routes) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_space(), boost::token_compress_on);

            // skip links that are linkdown
            if (std::find_if(parts.cbegin(), parts.cend(), [](const boost::iterator_range<string::iterator>& range) {
                return std::string(range.begin(), range.end()) == "linkdown";
            }) != parts.cend()) {
                return true;
            }

            // FACT-1282
            std::string route_type(parts[0].begin(), parts[0].end());
            if (known_route_types.find(route_type) != known_route_types.end()) {
                parts.erase(parts.begin());
            }

            route r;
            r.destination.assign(parts[0].begin(), parts[0].end());

            // Check if we queried for the IPV6 routing tables. If yes, then check if our
            // destination address is missing a ':'. If yes, then IPV6 is disabled since
            // IPV6 addresses have a ':' in them. Our ip command has mistakenly outputted IPV4
            // information. This is bogus data that we want to flush.
            //
            // See FACT-1475 for more details.
            if (family == AF_INET6 && r.destination.find(':') == string::npos) {
              routes = {};
              return false;
            }

            // Iterate over key/value pairs and add the ones we care
            // about to our routes entries
            for (size_t i = 1; i < parts.size(); i += 2) {
                std::string key(parts[i].begin(), parts[i].end());
                if (key == "dev") {
                    r.interface.assign(parts[i+1].begin(), parts[i+1].end());
                }
                if (key == "src") {
                    r.source.assign(parts[i+1].begin(), parts[i+1].end());
                }
            }
            routes.push_back(r);
            return true;
        };

        lth_exe::each_line(ip_command, { "route", "show" }, [this, &parse_route_line](string& line) {
            return parse_route_line(line, AF_INET, this->routes4);
        });
        lth_exe::each_line(ip_command, { "-6", "route", "show" }, [this, &parse_route_line](string& line) {
            return parse_route_line(line, AF_INET6, this->routes6);
        });
    }

    void networking_resolver::populate_from_routing_table(networking_resolver::data& result) const
    {
        for (const auto& r : routes4) {
            if (r.destination == "default" && result.primary_interface.empty()) {
                 result.primary_interface = r.interface;
            }
            associate_src_with_iface(r, result, [](interface& iface) -> vector<binding>& {
                return iface.ipv4_bindings;
            });
        }

        for (const auto& r : routes6) {
            associate_src_with_iface(r, result, [](interface& iface) -> vector<binding>& {
                return iface.ipv6_bindings;
            });
        }
    }

    template<typename F>
    void networking_resolver::associate_src_with_iface(const networking_resolver::route& r, networking_resolver::data& result, F get_bindings) const {
        if (!r.source.empty()) {
            auto iface = find_if(result.interfaces.begin(), result.interfaces.end(), [&](const interface& iface) {
                return iface.name == r.interface;
            });
            if (iface != result.interfaces.end()) {
                auto& bindings = get_bindings(*iface);
                auto existing_binding = find_if(bindings.begin(), bindings.end(), [&](const binding& b) {
                    return b.address == r.source;
                });
                if (existing_binding == bindings.end()) {
                    binding b = { r.source, "", "" };
                    bindings.emplace_back(move(b));
                }
            }
        }
    }

    string networking_resolver::get_bond_master(const std::string& name) const {
        static bool have_logged_about_bonding = false;
        auto ip_command = lth_exe::which("ip");
        if (ip_command.empty()) {
            if (!have_logged_about_bonding) {
                 LOG_DEBUG("Could not find the 'ip' command. Physical macaddress for bonded interfaces will be incorrect.");
                 have_logged_about_bonding = true;
            }
            return {};
        }

        string bonding_master;

        lth_exe::each_line(ip_command, {"link", "show", name}, [&bonding_master](string& line) {
            if (line.find("SLAVE") != string::npos) {
                vector<boost::iterator_range<string::iterator>> parts;
                boost::split(parts, line, boost::is_space(), boost::token_compress_on);

                // We have to use find_if here since a boost::iterator_range doesn't compare properly to a string.
                auto master = find_if(parts.begin(), parts.end(), [](boost::iterator_range<string::iterator>& part){
                    string p {part.begin(), part.end()};
                    return p == "master";
                });

                // the actual master interface is in the output as
                // "master <iface>". Once we've found the master
                // string above, we get the next token and return that
                // as our interface device.
                if (master != parts.end()) {
                    auto master_iface = master + 1;
                    if (master_iface != parts.end()) {
                        bonding_master.assign(master_iface->begin(), master_iface->end());
                        return false;
                    }
                }
            }
            return true;
        });
        return bonding_master;
    }
}}}  // namespace facter::facts::linux
