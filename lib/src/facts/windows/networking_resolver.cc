#include <internal/facts/windows/networking_resolver.hpp>
#include <leatherman/windows/registry.hpp>
#include <leatherman/windows/system_error.hpp>
#include <internal/util/windows/wsa.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/range/combine.hpp>
#include <boost/nowide/convert.hpp>
#include <iomanip>
#include <Ws2tcpip.h>
#include <iphlpapi.h>

#ifdef interface
  // Something's bleeding in and making it impossible to instantiate an interface object.
  #undef interface
#endif

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;
using namespace leatherman::windows;

namespace facter { namespace facts { namespace windows {

    networking_resolver::networking_resolver()
    {
    }

    static string get_computername(COMPUTER_NAME_FORMAT nameFormat)
    {
        DWORD size = 0u;
        GetComputerNameExW(nameFormat, nullptr, &size);
        if (GetLastError() != ERROR_MORE_DATA) {
            LOG_DEBUG("failure resolving hostname: {1}", leatherman::windows::system_error());
            return "";
        }

        wstring buffer(size, '\0');
        if (!GetComputerNameExW(nameFormat, &buffer[0], &size)) {
            LOG_DEBUG("failure resolving hostname: {1}", leatherman::windows::system_error());
            return "";
        }

        buffer.resize(size);
        return boost::nowide::narrow(buffer);
    }

    sockaddr_in networking_resolver::create_ipv4_mask(uint8_t masklen)
    {
        sockaddr_in mask = {AF_INET};
        if (ConvertLengthToIpv4Mask(masklen, &mask.sin_addr.S_un.S_addr) != NO_ERROR) {
            LOG_DEBUG("failed creating IPv4 mask of length {1}", masklen);
        }
        return mask;
    }

    sockaddr_in6 networking_resolver::create_ipv6_mask(uint8_t masklen)
    {
        sockaddr_in6 mask = {AF_INET6};
        const uint8_t incr = 32u;
        for (size_t i = 0; i < 16 && masklen > 0; i += 4, masklen -= min(masklen, incr)) {
            if (ConvertLengthToIpv4Mask(min(masklen, incr), reinterpret_cast<PULONG>(&mask.sin6_addr.u.Byte[i])) != NO_ERROR) {
                LOG_DEBUG("failed creating IPv6 mask with component of length {1}", incr);
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

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        data result;

        result.hostname = get_computername(ComputerNameDnsHostname);

        try {
            result.domain = registry::get_registry_string(registry::HKEY::LOCAL_MACHINE,
                "SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\", "Domain");
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting networking::domain fact: {1}", e.what());
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
                LOG_DEBUG("failure resolving networking facts: {1}", leatherman::windows::system_error(err));
                return result;
            }
        }

        if (err != ERROR_SUCCESS) {
            LOG_DEBUG("failure resolving networking facts: {1}", leatherman::windows::system_error(err));
            return result;
        }

        facter::util::windows::wsa winsock;

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

            // Only supported on platforms after Windows Server 2003.
            if (pCurAddr->Flags & IP_ADAPTER_DHCP_ENABLED && pCurAddr->Length >= sizeof(IP_ADAPTER_ADDRESSES_LH)) {
                auto adapter = reinterpret_cast<IP_ADAPTER_ADDRESSES_LH&>(*pCurAddr);
                if (adapter.Flags & IP_ADAPTER_DHCP_ENABLED) {
                    try {
                        net_interface.dhcp_server = winsock.saddress_to_string(adapter.Dhcpv4Server);
                    } catch (wsa_exception &e) {
                        LOG_DEBUG("failed to retrieve dhcp v4 server address for {1}: {2}", net_interface.name, e.what());
                    }
                }
            }

            for (auto it = pCurAddr->FirstUnicastAddress; it; it = it->Next) {
                string addr;
                try {
                    addr = winsock.saddress_to_string(it->Address);
                } catch (wsa_exception &e) {
                    string iptype =
                        (it->Address.lpSockaddr->sa_family == AF_INET) ? " v4"
                        : (it->Address.lpSockaddr->sa_family == AF_INET6) ? " v6"
                        : "";
                    LOG_DEBUG("failed to retrieve ip{1} address for {2}: {3}",
                        iptype, net_interface.name, e.what());
                }

                if (addr.empty()) {
                    continue;
                }

                if (it->Address.lpSockaddr->sa_family == AF_INET || it->Address.lpSockaddr->sa_family == AF_INET6) {
                    bool ipv6 = it->Address.lpSockaddr->sa_family == AF_INET6;

                    binding b;
                    b.address = addr;

                    // Need to do lookup based on the structure length.
                    auto adapterAddr = reinterpret_cast<IP_ADAPTER_UNICAST_ADDRESS_LH&>(*it);
                    if (ipv6) {
                        auto mask = create_ipv6_mask(adapterAddr.OnLinkPrefixLength);
                        auto masked = mask_ipv6_address(it->Address.lpSockaddr, mask);
                        b.netmask = winsock.address_to_string(mask);
                        b.network = winsock.address_to_string(masked);
                    } else {
                        auto mask = create_ipv4_mask(adapterAddr.OnLinkPrefixLength);
                        auto masked = mask_ipv4_address(it->Address.lpSockaddr, mask);
                        b.netmask = winsock.address_to_string(mask);
                        b.network = winsock.address_to_string(masked);
                    }

                    if (ipv6) {
                        net_interface.ipv6_bindings.emplace_back(std::move(b));
                    } else {
                        net_interface.ipv4_bindings.emplace_back(std::move(b));
                    }

                    // http://support.microsoft.com/kb/894564 talks about how binding order is determined.
                    // GetAdaptersAddresses returns adapters in binding order. This way, the domain and primary_interface match.
                    // The old facter behavior didn't make a lot of sense (it would pick the last in binding order, not 1st).
                    // Only accept this as a primary interface if it has a non-link-local address.
                    if (result.primary_interface.empty() && (
                        (it->Address.lpSockaddr->sa_family == AF_INET && !ignored_ipv4_address(addr)) ||
                        (it->Address.lpSockaddr->sa_family == AF_INET6 && !ignored_ipv6_address(addr)))) {
                        result.primary_interface = net_interface.name;
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
