#include <facter/facts/windows/networking_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/registry.hpp>
#include <facter/util/windows/system_error.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/range/combine.hpp>
#include <boost/nowide/convert.hpp>
#include <iomanip>

#include <facter/util/windows/windows.hpp>
#include <Ws2tcpip.h>
#include <iphlpapi.h>
#ifdef interface
  // Something's bleeding in and making it impossible to instantiate an interface object.
  #undef interface
#endif

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;
using namespace boost::algorithm;

namespace facter { namespace facts { namespace windows {

    static string get_computername(COMPUTER_NAME_FORMAT nameFormat)
    {
        DWORD size = 0u;
        GetComputerNameExW(nameFormat, nullptr, &size);
        if (GetLastError() != ERROR_MORE_DATA) {
            LOG_DEBUG("failure resolving hostname: %1%", system_error());
            return "";
        }

        wstring buffer(size, '\0');
        if (!GetComputerNameExW(nameFormat, &buffer[0], &size)) {
            LOG_DEBUG("failure resolving hostname: %1%", system_error());
            return "";
        }

        buffer.resize(size);
        return boost::nowide::narrow(buffer);
    }

    bool networking_resolver::ignored_ipv4_address(string const& addr)
    {
        // Excluding localhost and 169.254.x.x in Windows - this is the DHCP APIPA, meaning that if the node cannot
        // get an ip address from the dhcp server, it auto-assigns a private ip address
        return addr == "127.0.0.1" || boost::starts_with(addr, "169.254.");
    }

    bool networking_resolver::ignored_ipv6_address(string const& addr)
    {
        return addr == "::1" || boost::starts_with(addr, "fe80");
    }

    sockaddr_in networking_resolver::create_ipv4_mask(uint8_t masklen)
    {
        sockaddr_in mask = {AF_INET};
        if (ConvertLengthToIpv4Mask(masklen, &mask.sin_addr.S_un.S_addr) != NO_ERROR) {
            LOG_DEBUG("failed creating IPv4 mask of length %1%", masklen);
        }
        return mask;
    }

    sockaddr_in6 networking_resolver::create_ipv6_mask(uint8_t masklen)
    {
        sockaddr_in6 mask = {AF_INET6};
        const uint8_t incr = 32u;
        for (size_t i = 0; i < 16 && masklen > 0; i += 4, masklen -= min(masklen, incr)) {
            if (ConvertLengthToIpv4Mask(min(masklen, incr), reinterpret_cast<PULONG>(&mask.sin6_addr.u.Byte[i])) != NO_ERROR) {
                LOG_DEBUG("failed creating IPv6 mask with component of length %1%", incr);
                break;
            }
        }
        return mask;
    }

    string networking_resolver::address_to_string(sockaddr const* addr, sockaddr const* mask)
    {
        if (!addr) {
            return {};
        }

        // Check for IPv4 and IPv6
        if (addr->sa_family == AF_INET) {
            in_addr ip = reinterpret_cast<sockaddr_in const*>(addr)->sin_addr;

            // Apply an IPv4 mask
            if (mask && mask->sa_family == addr->sa_family) {
                ip.S_un.S_addr &= reinterpret_cast<sockaddr_in const*>(mask)->sin_addr.S_un.S_addr;
            }

            char buffer[INET_ADDRSTRLEN] = {};
            inet_ntop(AF_INET, &ip, buffer, sizeof(buffer));
            return buffer;
        } else if (addr->sa_family == AF_INET6) {
            in6_addr ip = reinterpret_cast<sockaddr_in6 const*>(addr)->sin6_addr;

            // Apply an IPv6 mask
            if (mask && mask->sa_family == addr->sa_family) {
                auto mask_ptr = reinterpret_cast<sockaddr_in6 const*>(mask);
                for (size_t i = 0; i < 8; ++i) {
                    ip.u.Word[i] &= mask_ptr->sin6_addr.u.Word[i];
                }
            }

            char buffer[INET6_ADDRSTRLEN] = {};
            inet_ntop(AF_INET6, &ip, buffer, sizeof(buffer));
            return buffer;
        }

        return {};
    }

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        data result;

        result.hostname = get_computername(ComputerNameDnsHostname);

        try {
            result.domain = registry::get_registry_string(registry::HKEY::LOCAL_MACHINE,
                "SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\", "Domain");
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting networking::domain fact: %1%", e.what());
        }

        // Get linked list of adapters.
        ULONG family = AF_UNSPEC;
        ULONG flags = GAA_FLAG_SKIP_ANYCAST | GAA_FLAG_SKIP_MULTICAST | GAA_FLAG_SKIP_DNS_SERVER;

        // Pre-allocate and try several times, because the adapter configuration may change between calls.
        ULONG outBufLen = 15000;
        vector<char> pAddresses(outBufLen);
        DWORD err;
        for (int i = 0; i < 3; ++i) {
            err = GetAdaptersAddresses(family, flags, nullptr,
                reinterpret_cast<PIP_ADAPTER_ADDRESSES>(pAddresses.data()), &outBufLen);
            if (err == ERROR_SUCCESS) {
                break;
            } else if (err == ERROR_BUFFER_OVERFLOW) {
                pAddresses.resize(outBufLen);
            } else {
                LOG_DEBUG("failure resolving networking facts: %1%", system_error(err));
                return result;
            }
        }

        if (err != ERROR_SUCCESS) {
            LOG_DEBUG("failure resolving networking facts: %1%", system_error(err));
            return result;
        }

        for (auto pCurAddr = reinterpret_cast<PIP_ADAPTER_ADDRESSES>(pAddresses.data());
            pCurAddr; pCurAddr = pCurAddr->Next) {
            if (pCurAddr->OperStatus != IfOperStatusUp ||
                (pCurAddr->IfType != IF_TYPE_ETHERNET_CSMACD && pCurAddr->IfType != IF_TYPE_IEEE80211)) {
                continue;
            }

            if (result.domain.empty()) {
                // If domain isn't set in the registry, fall back to the first DnsDomain encountered in the adapters.
                result.domain = boost::nowide::narrow(pCurAddr->DnsSuffix);
            }

            interface net_interface;
            net_interface.name = boost::nowide::narrow(pCurAddr->FriendlyName);

            // http://support.microsoft.com/kb/894564 talks about how binding order is determined.
            // GetAdaptersAddresses returns adapters in binding order. This way, the domain and primary_interface match.
            // The old facter behavior didn't make a lot of sense (it would pick the last in binding order, not 1st).
            if (result.primary_interface.empty()) {
                result.primary_interface = net_interface.name;
            }

            if (pCurAddr->Flags & IP_ADAPTER_DHCP_ENABLED) {
                net_interface.dhcp_server = address_to_string(pCurAddr->Dhcpv4Server.lpSockaddr);
            }

            for (auto it = pCurAddr->FirstUnicastAddress; it; it = it->Next) {
                string addr = address_to_string(it->Address.lpSockaddr);
                if (addr.empty()) {
                    continue;
                }

                if (it->Address.lpSockaddr->sa_family == AF_INET && !ignored_ipv4_address(addr)) {
                    auto mask = create_ipv4_mask(it->OnLinkPrefixLength);
                    net_interface.address.v4 = move(addr);
                    net_interface.netmask.v4 = address_to_string(reinterpret_cast<sockaddr *>(&mask));
                    net_interface.network.v4 = address_to_string(it->Address.lpSockaddr, reinterpret_cast<sockaddr *>(&mask));
                } else if (it->Address.lpSockaddr->sa_family == AF_INET6 && !ignored_ipv6_address(addr)) {
                    auto mask = create_ipv6_mask(it->OnLinkPrefixLength);
                    net_interface.address.v6 = move(addr);
                    net_interface.netmask.v6 = address_to_string(reinterpret_cast<sockaddr *>(&mask));
                    net_interface.network.v6 = address_to_string(it->Address.lpSockaddr, reinterpret_cast<sockaddr *>(&mask));
                }
            }

            stringstream macaddr;
            for (DWORD i = 0u; i < pCurAddr->PhysicalAddressLength; ++i) {
                macaddr << setfill('0') << setw(2) << hex << uppercase <<
                    static_cast<int>(pCurAddr->PhysicalAddress[i]) << ':';
            }
            net_interface.macaddress = macaddr.str();
            if (!net_interface.macaddress.empty()) {
                net_interface.macaddress.pop_back();
            }

            net_interface.mtu = pCurAddr->Mtu;

            result.interfaces.emplace_back(move(net_interface));
        }

        return result;
    }

}}}  // namespace facter::facts::windows
