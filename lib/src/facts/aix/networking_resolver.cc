#include <internal/facts/aix/networking_resolver.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>

#include <unordered_map>

#include <inttypes.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <net/route.h>
#include <netinet/in.h>
#include <sys/kinfo.h>

// This usage is recommended in several mailing lists, and is used at
// least in Samba to query mac addresses. I saw some references to old
// IBM publications also recommending its use, but couldn't actually
// dig those pubs up.
//
// The structs it *returns* are in headers, though (specifically
// mentioning usage of this function).
//
// This is all leftovers from ancient versions of the BSD networking
// stack that every OS in the world has stolen/borrowed. It is pretty
// gross in a lot of ways, but is what we have to work with on AIX.
//
// There does not appear to be a different or documented way to get
// this information, outside of shelling out to tools which provide
// human- rather than machine-readable output.
extern "C" int getkerninfo(int, char*, int*, int32long64_t);

template <typename T>
static std::vector<T> getkerninfo(int query) {
    for (;;) {
        auto ksize = getkerninfo(query, nullptr, nullptr, 0);
        if (ksize == 0) {
            throw std::runtime_error("getkerninfo call was unsuccessful");
        }
        auto alloc_size = ksize;
        auto count = alloc_size/sizeof(T);
        std::vector<T> result(count);
        if (getkerninfo(query, reinterpret_cast<char*>(result.data()), &ksize, 0) == -1) {
            throw std::runtime_error("getkerninfo call was unsuccessful");
        }

        // getkerninfo updates the size variable to match our actual
        // buffer size. If we need more space we loop to
        // reallocate. Otherwise we make sure the vector is trimmed to
        // the proper size and return the contents.
        if (ksize <= alloc_size) {
            result.resize(ksize/sizeof(T));
            return result;
        }
    }
}

namespace facter { namespace facts { namespace aix {
    networking_resolver::data networking_resolver::collect_data(collection& facts) {
        auto data = posix::networking_resolver::collect_data(facts);

        // Query the kernel for the list of network interfaces and
        // their associated addresses
        data.interfaces = get_interfaces();

        // query the network device descriptors from the kernel. This
        // gives us physical information, such as mtu.
        auto mtus = get_mtus();

        for (auto& iface : data.interfaces) {
            auto mtu_iter = mtus.find(iface.name);
            if (mtu_iter != mtus.end()) {
                iface.mtu = stoll(mtu_iter->second);
            }
        }

        data.primary_interface = get_primary_interface();

        return data;
    }

    networking_resolver::mtu_map networking_resolver::get_mtus() const {
        mtu_map result;
        leatherman::execution::each_line("/usr/bin/netstat", {"-in"}, [&](std::string line) {
            std::vector<std::string> fields;
            boost::trim(line);
            boost::split(fields, line, boost::is_space(), boost::token_compress_on);
            if (boost::starts_with(fields[2], "link")) {
                result[fields[0]] = fields[1];
            }
            return true;
        });
        return result;
    }

    std::vector<networking_resolver::interface> networking_resolver::get_interfaces() const {
        auto buffer = getkerninfo<char>(KINFO_RT_IFLIST);

        // interfaces are identified by 16-bit IDs. these may or may
        // not be sequential, so we use a map as a sparse array
        std::map<u_short, interface> ifaces;

        decltype(buffer)::size_type cursor = 0;
        while (cursor < buffer.size()) {
            if_msghdr* hdr = reinterpret_cast<if_msghdr*>(buffer.data() + cursor);

            switch (hdr->ifm_type) {
            case RTM_IFINFO: {
                sockaddr_dl* link_addr = reinterpret_cast<sockaddr_dl*>(hdr+1);  // sockaddr immediately follows the header

                // Name is not zero-terminated, we must pass the length to the string constructor.
                ifaces[hdr->ifm_index].name = std::string(link_addr->sdl_data, link_addr->sdl_nlen);

                // The mac address is stored in binary immediately following the name length
                ifaces[hdr->ifm_index].macaddress = macaddress_to_string(reinterpret_cast<uint8_t*>(link_addr->sdl_data+link_addr->sdl_nlen));
                break;
            }
            case RTM_NEWADDR: {
                // This is gross. Immediately following the header is
                // a number of addresses which may or may not
                // individually be present based on a bitfield. They
                // are stored in a specific order, at least.
                // Additionally, each address struct could be cut off
                // or padded - we need to check the length of each one
                // to know where the next one starts. PLUS we don't
                // know whether we're looking at IPV4 or IPV6 until we
                // find an address that actually specifies its
                // protocol (the first one might not).

                // sockaddr_storage is guaranteed to be big enough for the memcpy below.
                std::array<sockaddr_storage, RTAX_MAX> addrs;
                memset(addrs.data(), 0, RTAX_MAX*sizeof(sockaddr_storage));

                // This represents our position walking the list of address objects
                int addr_cursor = cursor + sizeof(if_msghdr);

#define FACT_READ_ADDR(a) if (hdr->ifm_addrs & RTA_##a) { \
                    sockaddr* sa = reinterpret_cast<sockaddr*>(buffer.data()+addr_cursor); \
                    memcpy(&(addrs[ RTAX_##a ]), sa, sa->sa_len); \
                    addr_cursor += RT_ROUNDUP(sa); \
                }
                FACT_READ_ADDR(DST);
                FACT_READ_ADDR(GATEWAY);
                FACT_READ_ADDR(NETMASK);
                FACT_READ_ADDR(GENMASK);
                FACT_READ_ADDR(IFP);
                FACT_READ_ADDR(IFA);
                FACT_READ_ADDR(AUTHOR);
                FACT_READ_ADDR(BRD);

                // WOO addresses read. Now we try to figure out if
                // we're IPv4 or IPv6. We skip any other families, and
                // warn if we get a mixed set of families.

                int family = AF_UNSPEC;
                for (const auto& addr : addrs) {
                    if (family != AF_UNSPEC &&
                        addr.ss_family != AF_UNSPEC &&
                        family != addr.ss_family) {
                        family = AF_MAX;
                        break;
                    }
                    family = addr.ss_family;
                }

                binding addr_binding;
                sockaddr* netmask = reinterpret_cast<sockaddr*>(&addrs[RTAX_NETMASK]);
                sockaddr* address = reinterpret_cast<sockaddr*>(&addrs[RTAX_IFA]);
                if (netmask->sa_len) {
                    netmask->sa_family = family;  // AIX likes to return the netmask with AF_UNSPEC family.
                    addr_binding.netmask = address_to_string(netmask);
                }
                if (address->sa_len) {
                    addr_binding.address = address_to_string(address);
                }
                if (address->sa_len && netmask->sa_len) {
                    addr_binding.network = address_to_string(address, netmask);
                }

                if (family == AF_MAX) {
                    LOG_WARNING("got mixed address families for interface %1%, can't map them to a single binding.", ifaces[hdr->ifm_index].name);
                } else if (family == AF_INET) {
                    LOG_INFO("got ipv4 addresses for interface %1%", ifaces[hdr->ifm_index].name);
                    ifaces[hdr->ifm_index].ipv4_bindings.push_back(addr_binding);
                } else if (family == AF_INET6) {
                    LOG_INFO("got ipv6 addresses for interface %1%", ifaces[hdr->ifm_index].name);
                    ifaces[hdr->ifm_index].ipv6_bindings.push_back(addr_binding);
                } else if (family != AF_UNSPEC) {
                    LOG_INFO("skipping unknown address family %1% for interface %2%", family, ifaces[hdr->ifm_index].name);
                } else {
                    LOG_INFO("somehow didn't get an address family for interface %1%", ifaces[hdr->ifm_index].name);
                }
                break;
            }
            default: {
                LOG_INFO("got an unknown RT_IFLIST message: %1%", hdr->ifm_type);
                break;
            }
            }

            cursor += hdr->ifm_msglen;
        }

        // Now that we're done processing the data we don't care about
        // the kernel's iface IDs anymore.
        std::vector<interface> result;
        for (auto& iface : ifaces) {
            result.push_back(iface.second);
        }
        return result;
    }

    std::string networking_resolver::get_primary_interface() const
    {
        std::string value;
        leatherman::execution::each_line("netstat", { "-rn"}, [&value](std::string& line) {
            boost::trim(line);
            if (boost::starts_with(line, "default")) {
                std::vector<std::string> fields;
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
        // We explicitly populate the MAC address; we don't need address_to_string to support link layer addresses
        return false;
    }

    uint8_t const* networking_resolver::get_link_address_bytes(const sockaddr * addr) const
    {
        return nullptr;
    }


}}}  // namespace facter::facts::aix
