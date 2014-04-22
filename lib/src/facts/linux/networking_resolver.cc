#include <facts/linux/networking_resolver.hpp>
#include <facts/fact_map.hpp>
#include <facts/string_value.hpp>
#include <util/posix/scoped_descriptor.hpp>
#include <cstring>
#include <netpacket/packet.h>
#include <net/if.h>
#include <sys/ioctl.h>

using namespace std;
using namespace cfacter::util::posix;

namespace cfacter { namespace facts { namespace linux {

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

    int networking_resolver::get_link_mtu(string const& interface, void* data) const
    {
        // Unfortunately in Linux, the data points at interface statistics
        // Nothing useful for us, so we need to use ioctl to query the MTU
        ifreq req;
        memset(&req, 0, sizeof(req));
        strncpy(req.ifr_name, interface.c_str(), sizeof(req.ifr_name));

        scoped_descriptor sock(socket(AF_INET, SOCK_DGRAM, 0));

        if (ioctl(sock, SIOCGIFMTU, &req) != 0) {
            // TODO: log failure
            return -1;
        }
        return req.ifr_mtu;
    }

}}}  // namespace cfacter::facts::linux
