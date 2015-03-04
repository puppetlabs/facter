#include <internal/facts/windows/networking_resolver.hpp>
#include <internal/util/windows/registry.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/wsa.hpp>
#include <internal/util/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/range/combine.hpp>
#include <boost/nowide/convert.hpp>
#include <iomanip>
#include <Ws2tcpip.h>
#include <iphlpapi.h>

#ifdef interface
  // Something's bleeding in and making it impossible to instantiate an interface object.
  #undef interface
#endif

#define WIN_SERVER_2003_SUPPORT

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;
using namespace boost::algorithm;

namespace facter { namespace facts { namespace windows {

    networking_resolver::networking_resolver()
    {
        // Find ConvertLengthToIpv4Mask and save it to _convertLengthToIpv4Mask. Won't be found on
        // Windows Server 2003, but in 2003 we get masks as strings so this function isn't needed.
        auto func = GetProcAddress(GetModuleHandleW(L"Iphlpapi"), "ConvertLengthToIpv4Mask");
        if (nullptr != func) {
            typedef int (WINAPI *LPFN_CONVLEN) (ULONG, PULONG);
            _convertLengthToIpv4Mask = reinterpret_cast<LPFN_CONVLEN>(func);
        }
    }

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
        if (_convertLengthToIpv4Mask && _convertLengthToIpv4Mask(masklen, &mask.sin_addr.S_un.S_addr) != NO_ERROR) {
            LOG_DEBUG("failed creating IPv4 mask of length %1%", masklen);
        }
        return mask;
    }

    sockaddr_in6 networking_resolver::create_ipv6_mask(uint8_t masklen)
    {
        sockaddr_in6 mask = {AF_INET6};
        const uint8_t incr = 32u;
        for (size_t i = 0; i < 16 && masklen > 0; i += 4, masklen -= min(masklen, incr)) {
            if (_convertLengthToIpv4Mask && _convertLengthToIpv4Mask(min(masklen, incr), reinterpret_cast<PULONG>(&mask.sin6_addr.u.Byte[i])) != NO_ERROR) {
                LOG_DEBUG("failed creating IPv6 mask with component of length %1%", incr);
                break;
            }
        }
        return mask;
    }

    sockaddr_in networking_resolver::mask_ipv4_address(sockaddr const* addr, sockaddr_in const& mask)
    {
        sockaddr_in masked = *reinterpret_cast<sockaddr_in const*>(addr);
        masked.sin_addr.S_un.S_addr &= mask.sin_addr.S_un.S_addr;
        return masked;
    }

    sockaddr_in6 networking_resolver::mask_ipv6_address(sockaddr const* addr, sockaddr_in6 const& mask)
    {
        sockaddr_in6 masked = *reinterpret_cast<sockaddr_in6 const*>(addr);
        for (size_t i = 0; i < 8; ++i) {
            masked.sin6_addr.u.Word[i] &= mask.sin6_addr.u.Word[i];
        }
        return masked;
    }

#ifdef WIN_SERVER_2003_SUPPORT
    // Provided to get network masks on Windows Server 2003.
    // Returns a map of IP addresses to their network masks and dhcp servers (if enabled),
    // obtained using GetAdapterInfo. Only works for IPv4.
    static map<string, pair<string, string>> legacy_get_masks()
    {
        ULONG outBufLen = 15000;
        vector<char> pAddresses(outBufLen);
        DWORD err;
        for (int i = 0; i < 3; ++i) {
            err = GetAdaptersInfo(reinterpret_cast<PIP_ADAPTER_INFO>(pAddresses.data()), &outBufLen);
            if (err == ERROR_SUCCESS) {
                break;
            } else if (err == ERROR_BUFFER_OVERFLOW) {
                pAddresses.resize(outBufLen);
            } else {
                LOG_DEBUG("failure getting netmask info: %1%", system_error(err));
                return {};
            }
        }

        if (err != ERROR_SUCCESS) {
            LOG_DEBUG("failure getting netmask info: %1%", system_error(err));
            return {};
        }

        map<string, pair<string, string>> ip_masks;
        for (auto pCurAddr = reinterpret_cast<PIP_ADAPTER_INFO>(pAddresses.data());
            pCurAddr; pCurAddr = pCurAddr->Next) {
            string dhcp;
            if (pCurAddr->DhcpEnabled) {
                dhcp = pCurAddr->DhcpServer.IpAddress.String;
            }
            for (auto it = &(pCurAddr->IpAddressList); it; it = it->Next) {
                ip_masks.insert(make_pair(it->IpAddress.String, make_pair(string(it->IpMask.String), dhcp)));
            }
        }
        LOG_DEBUG("found %1% netmask entries", ip_masks.size());
        return ip_masks;
    }
#endif

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

        wsa winsock;

        map<string, pair<string, string>> adapterInfoMasks;
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

            // Only supported on platforms after Windows Server 2003.
            if (pCurAddr->Flags & IP_ADAPTER_DHCP_ENABLED && pCurAddr->Length >= sizeof(IP_ADAPTER_ADDRESSES_LH)) {
                auto adapter = reinterpret_cast<IP_ADAPTER_ADDRESSES_LH&>(*pCurAddr);
                net_interface.dhcp_server = winsock.saddress_to_string(adapter.Dhcpv4Server);
            }

            for (auto it = pCurAddr->FirstUnicastAddress; it; it = it->Next) {
                string addr = winsock.saddress_to_string(it->Address);
                if (addr.empty()) {
                    continue;
                }

#ifdef WIN_SERVER_2003_SUPPORT
                // Use length of IP_ADAPTER_ADDRESSES. The length of the unicast address struct doesn't differ between LH and XP
                // due to padding, so it can't be used.
                if (pCurAddr->Length < sizeof(IP_ADAPTER_ADDRESSES_LH)) {
                    if (adapterInfoMasks.empty()) {
                        adapterInfoMasks = legacy_get_masks();
                    }

                    // Set the DHCP server on Windows Server 2003.
                    auto ip_mask = adapterInfoMasks.find(addr);
                    if (ip_mask != adapterInfoMasks.end()) {
                        net_interface.dhcp_server = ip_mask->second.second;
                    }
                }
#endif

                if (it->Address.lpSockaddr->sa_family == AF_INET && !ignored_ipv4_address(addr)) {
                    net_interface.address.v4 = move(addr);

                    if (adapterInfoMasks.empty()) {
                        // Need to do lookup based on the structure length.
                        auto adapterAddr = reinterpret_cast<IP_ADAPTER_UNICAST_ADDRESS_LH&>(*it);
                        auto mask = create_ipv4_mask(adapterAddr.OnLinkPrefixLength);
                        net_interface.netmask.v4 = winsock.address_to_string(mask);

                        auto masked = mask_ipv4_address(it->Address.lpSockaddr, mask);
                        net_interface.network.v4 = winsock.address_to_string(masked);
                    } else {
#ifdef WIN_SERVER_2003_SUPPORT
                        auto ip_mask = adapterInfoMasks.find(net_interface.address.v4);
                        if (ip_mask != adapterInfoMasks.end()) {
                            net_interface.netmask.v4 = ip_mask->second.first;

                            auto mask = winsock.string_to_address<sockaddr_in, AF_INET>(ip_mask->second.first);
                            auto masked = mask_ipv4_address(it->Address.lpSockaddr, mask);
                            net_interface.network.v4 = winsock.address_to_string(masked);
                        } else {
                            LOG_DEBUG("could not find netmask for %1%", net_interface.address.v4);
                        }
#endif
                    }
                } else if (it->Address.lpSockaddr->sa_family == AF_INET6 && !ignored_ipv6_address(addr)) {
                    net_interface.address.v6 = move(addr);

                    // Get mask if on a system later than Windows Server 2003. On 2003, we can't retrieve IPv6 masks.
                    if (adapterInfoMasks.empty()) {
                        auto adapterAddr = reinterpret_cast<IP_ADAPTER_UNICAST_ADDRESS_LH&>(*it);
                        auto mask = create_ipv6_mask(adapterAddr.OnLinkPrefixLength);
                        net_interface.netmask.v6 = winsock.address_to_string(mask);

                        auto masked = mask_ipv6_address(it->Address.lpSockaddr, mask);
                        net_interface.network.v6 = winsock.address_to_string(masked);
                    } else {
#ifdef WIN_SERVER_2003_SUPPORT
                        LOG_DEBUG("netmask for %1% (IPv6) is not supported on this platform", net_interface.address.v6);
#endif
                    }
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
