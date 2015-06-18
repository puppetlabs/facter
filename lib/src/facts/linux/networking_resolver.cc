#include <internal/facts/linux/networking_resolver.hpp>
#include <internal/util/posix/scoped_descriptor.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <cstring>
#include <netpacket/packet.h>
#include <net/if.h>
#include <sys/ioctl.h>

using namespace std;
using namespace facter::util::posix;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

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

}}}  // namespace facter::facts::linux
