#include <internal/facts/linux/networking_resolver.hpp>
#include <internal/util/posix/scoped_descriptor.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <algorithm>
#include <cstring>
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
        if (link_addr->sll_halen != 6) {
            return nullptr;
        }
        return reinterpret_cast<uint8_t const*>(link_addr->sll_addr);
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
            LOG_WARNING("socket failed: %1% (%2%): interface MTU fact is unavailable for interface %3%.", strerror(errno), errno, interface);
            return boost::none;
        }

        if (ioctl(sock, SIOCGIFMTU, &req) == -1) {
            LOG_WARNING("ioctl failed: %1% (%2%): interface MTU fact is unavailable for interface %3%.", strerror(errno), errno, interface);
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
            if (parts.size() > 1 && parts[1] == boost::as_literal("00000000")) {
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

        auto parse_route_line = [](string& line, std::vector<route>& routes) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_space(), boost::token_compress_on);
            if (parts.size() % 2 != 1) {
                LOG_WARNING("Could not process routing table entry: Expected a destination followed by key/value pairs, got '%1%'", line);
                return true;
            }

            route r;
            r.destination.assign(parts[0].begin(), parts[0].end());
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
            return parse_route_line(line, this->routes4);
        });
        lth_exe::each_line(ip_command, { "-6", "route", "show" }, [this, &parse_route_line](string& line) {
            return parse_route_line(line, this->routes6);
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
}}}  // namespace facter::facts::linux
