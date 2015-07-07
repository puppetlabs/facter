#include <internal/util/windows/wsa.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/nowide/convert.hpp>
#include <Ws2tcpip.h>

using namespace std;

namespace facter { namespace util { namespace windows {

    wsa_exception::wsa_exception(string const& message) :
        runtime_error(message)
    {
    }

    string format_err(char const* s, int err)
    {
        return str(boost::format("%1% (%2%)") % s % boost::io::group(hex, showbase, err));
    }

    wsa::wsa()
    {
        LOG_DEBUG("initializing Winsock");
        WSADATA wsaData;
        auto wVersionRequested = MAKEWORD(2, 2);
        auto err = WSAStartup(wVersionRequested, &wsaData);

        if (err != 0) {
            throw wsa_exception(format_err("WSAStartup failed with error", err));
        }

        if (LOBYTE(wsaData.wVersion) != 2 || HIBYTE(wsaData.wVersion) != 2) {
            throw wsa_exception("could not find a usable version of Winsock.dll");
        }
    }

    wsa::~wsa()
    {
        WSACleanup();
    }

    string wsa::saddress_to_string(SOCKET_ADDRESS const& addr) const
    {
        if (!addr.lpSockaddr) {
            return {};
        }

        DWORD size = INET6_ADDRSTRLEN+1;
        wchar_t buffer[INET6_ADDRSTRLEN+1];
        if (0 != WSAAddressToStringW(addr.lpSockaddr, addr.iSockaddrLength, NULL, buffer, &size)) {
            throw wsa_exception(format_err("address to string translation failed", WSAGetLastError()));
        }

        return boost::nowide::narrow(buffer);
    }

    void wsa::string_fill_sockaddr(sockaddr *sock, std::string const& addr, int size) const
    {
        auto addrW = boost::nowide::widen(addr);
        if (0 != WSAStringToAddressW(&addrW[0], sock->sa_family, NULL, sock, &size)) {
            throw wsa_exception(format_err("string to address translation failed", WSAGetLastError()));
        }
    }

}}}  // namespace facter::util::windows
