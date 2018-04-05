#include <internal/facts/openbsd/networking_resolver.hpp>
#include <internal/util/bsd/scoped_ifaddrs.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <sys/sockio.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::bsd;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace openbsd {

    bool networking_resolver::is_link_address(sockaddr const* addr) const
    {
        return addr && addr->sa_family == AF_LINK;
    }

    uint8_t const* networking_resolver::get_link_address_bytes(sockaddr const* addr) const
    {
        if (!is_link_address(addr)) {
            return nullptr;
        }
        sockaddr_dl const* link_addr = reinterpret_cast<sockaddr_dl const*>(addr);
        if (link_addr->sdl_alen != 6 && link_addr->sdl_alen != 20) {
            return nullptr;
        }
        return reinterpret_cast<uint8_t const*>(LLADDR(link_addr));
     }

    uint8_t networking_resolver::get_link_address_length(sockaddr const* addr) const
    {
        if (!is_link_address(addr)) {
            return 0;
        }
        sockaddr_dl const* link_addr = reinterpret_cast<sockaddr_dl const*>(addr);
        return link_addr->sdl_alen;
    }

    boost::optional<uint64_t> networking_resolver::get_link_mtu(string const& interface, void* data) const
    {
        ifreq ifr;
        memset(&ifr, 0, sizeof(ifr));
        strncpy(ifr.ifr_name, interface.c_str(), sizeof(ifr.ifr_name));
        int s = socket(AF_INET, SOCK_DGRAM, 0);
        if (s < 0) {
            LOG_WARNING("socket failed: {1} ({2}): interface MTU fact is unavailable for interface {3}.", strerror(errno), errno, interface);
            return boost::none;
        }

        if (ioctl(s, SIOCGIFMTU, &ifr) == -1) {
            LOG_WARNING("ioctl failed: {1} ({2}): interface MTU fact is unavailable for interface {3}.", strerror(errno), errno, interface);
            return boost::none;
        }

        return ifr.ifr_mtu;
    }

}}}  // namespace facter::facts::openbsdbsd
