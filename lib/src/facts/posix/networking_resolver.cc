#include <facter/facts/posix/networking_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/posix/scoped_addrinfo.hpp>
#include <facter/util/string.hpp>
#include <unistd.h>
#include <limits.h>
#include <limits>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sstream>
#include <iomanip>
#include <cstring>
#include <vector>
#include <boost/format.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::util::posix;
using boost::format;

LOG_DECLARE_NAMESPACE("facts.posix.networking");

namespace facter { namespace facts { namespace posix {

    void networking_resolver::resolve_facts(fact_map& facts)
    {
        resolve_hostname(facts);
        resolve_domain(facts);
        resolve_interface_facts(facts);
    }

    void networking_resolver::resolve_hostname(fact_map& facts)
    {
        int max = sysconf(_SC_HOST_NAME_MAX);
        vector<char> name(max);
        if (gethostname(name.data(), max) != 0) {
            LOG_WARNING("gethostname failed: %1% (%2%): hostname fact is unavailable.", strerror(errno), errno);
            return;
        }

        // Use everything up to the first period
        string value = name.data();
        size_t pos = value.find('.');
        if (pos != string::npos) {
           value = value.substr(0, pos);
        }
        if (value.empty()) {
            return;
        }

        facts.add(fact::hostname, make_value<string_value>(move(value)));
    }

    void networking_resolver::resolve_domain(fact_map& facts)
    {
        auto hostname = facts.get<string_value>(fact::hostname, false);
        if (!hostname) {
            LOG_WARNING("domain and fqdn facts cannot be resolved without the hostname fact.");
            return;
        }

        // Retrieve the fully-qualified domain name
        scoped_addrinfo info(hostname->value());
        if (info.result() != 0) {
            if (info.result() == EAI_NONAME) {
                LOG_WARNING("domain is unknown for host %1%: domain and fqdn facts are unavailable.", hostname->value());
                return;
            }
            LOG_WARNING("getaddrinfo failed: %1% (%2%): domain and fqdn facts are unavailable.", gai_strerror(info.result()), info.result());
            return;
        }

        if (!info) {
            return;
        }

        // Add the FQDN fact
        string domain = static_cast<addrinfo*>(info)->ai_canonname;
        facts.add(fact::fqdn, make_value<string_value>(domain));

        // Trim off the hostname from the FQDN to get the domain fact
        if (starts_with(domain, hostname->value() + ".")) {
            domain = domain.substr(hostname->value().length() + 1);
        }
        facts.add(fact::domain, make_value<string_value>(move(domain)));
    }

    string networking_resolver::address_to_string(sockaddr const* addr, sockaddr const* mask) const
    {
        if (!addr) {
            return {};
        }

        // Check for IPv4 and IPv6
        if (addr->sa_family == AF_INET) {
            in_addr ip = reinterpret_cast<sockaddr_in const*>(addr)->sin_addr;

            // Apply an IPv4 mask
            if (mask && mask->sa_family == addr->sa_family) {
                ip.s_addr &= reinterpret_cast<sockaddr_in const*>(mask)->sin_addr.s_addr;
            }
            return inet_ntoa(ip);
        } else if (addr->sa_family == AF_INET6) {
            in6_addr ip = reinterpret_cast<sockaddr_in6 const*>(addr)->sin6_addr;

            // Apply an IPv6 mask
            if (mask && mask->sa_family == addr->sa_family) {
                in6_addr mask_ip = reinterpret_cast<sockaddr_in6 const*>(mask)->sin6_addr;
                for (size_t i = 0; i < 16; ++i) {
                    ip.s6_addr[i] &= mask_ip.s6_addr[i];
                }
            }
            char buffer[INET6_ADDRSTRLEN] = {};
            inet_ntop(AF_INET6, &ip, buffer, sizeof(buffer));
            return buffer;
        } else {
            auto link_addr = get_link_address_bytes(addr);
            if (link_addr) {
                return macaddress_to_string(reinterpret_cast<uint8_t const*>(link_addr));
            }
        }

        return {};
    }

    string networking_resolver::macaddress_to_string(uint8_t const* bytes)
    {
        if (!bytes) {
            return {};
        }

        // Ignore MAC address "0"
        bool nonzero = false;
        for (size_t i = 0; i < 6; ++i) {
            if (bytes[i] != 0) {
                nonzero = true;
                break;
            }
        }
        if (!nonzero) {
            return {};
        }

        return (format("%02x:%02x:%02x:%02x:%02x:%02x") %
                static_cast<int>(bytes[0]) % static_cast<int>(bytes[1]) %
                static_cast<int>(bytes[2]) % static_cast<int>(bytes[3]) %
                static_cast<int>(bytes[4]) % static_cast<int>(bytes[5])).str();
    }

}}}  // namespace facter::facts::posix
