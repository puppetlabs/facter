#include <internal/facts/posix/networking_resolver.hpp>
#include <internal/util/posix/scoped_addrinfo.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <unistd.h>
#include <limits.h>
#include <netinet/in.h>
#include <arpa/inet.h>

using namespace std;
using namespace facter::util::posix;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace posix {

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

            char buffer[INET_ADDRSTRLEN] = {};
            inet_ntop(AF_INET, &ip, buffer, sizeof(buffer));
            return buffer;
        } else if (addr->sa_family == AF_INET6) {
            in6_addr ip = reinterpret_cast<sockaddr_in6 const*>(addr)->sin6_addr;

            // Apply an IPv6 mask
            if (mask && mask->sa_family == addr->sa_family) {
                auto mask_ptr = reinterpret_cast<sockaddr_in6 const*>(mask);
                for (size_t i = 0; i < 16; ++i) {
                    ip.s6_addr[i] &= mask_ptr->sin6_addr.s6_addr[i];
                }
            }

            char buffer[INET6_ADDRSTRLEN] = {};
            inet_ntop(AF_INET6, &ip, buffer, sizeof(buffer));
            return buffer;
        } else if (is_link_address(addr)) {
            auto link_addr = get_link_address_bytes(addr);
            if (link_addr) {
                return macaddress_to_string(reinterpret_cast<uint8_t const*>(link_addr));
            }
        }

        return {};
    }

    networking_resolver::data networking_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the maximum size of the host name
        int size = sysconf(_SC_HOST_NAME_MAX);
        if (size <= 0) {
            size = 1024;
        }
        // Get the hostname (+1 to ensure a null is returned on platforms where maximum truncation may occur)
        vector<char> name(size + 1);
        if (gethostname(name.data(), size + 1) != 0) {
            LOG_WARNING("gethostname failed: {1} ({2}): hostname is unavailable.", strerror(errno), errno);
        } else {
            // Check for fully-qualified hostname
            auto it = find(name.begin(), name.end(), '.');
            if (it != name.end()) {
                LOG_DEBUG("using the FQDN returned by gethostname: {1}.", name.data());
                result.hostname.assign(name.begin(), it);
                if (++it != name.end()) {
                    // Use the remainder of the string, up to the first null character
                    result.domain = &*it;
                }
            } else {
                // Not fully qualified; just set hostname
                result.hostname = name.data();
            }
        }

        // If the hostname was not already fully qualified, attempt to resolve it
        if (result.domain.empty() && !result.hostname.empty()) {
            // Retrieve the FQDN by resolving the hostname
            scoped_addrinfo info(result.hostname);
            if (info.result() != 0 && info.result() != EAI_NONAME) {
                LOG_WARNING("getaddrinfo failed: {1} ({2}): hostname may not be externally resolvable.", gai_strerror(info.result()), info.result());
            } else if (!info || info.result() == EAI_NONAME || result.hostname == static_cast<addrinfo*>(info)->ai_canonname) {
                LOG_DEBUG("hostname \"{1}\" could not be resolved: hostname may not be externally resolvable.", result.hostname);
            } else {
                result.fqdn = static_cast<addrinfo*>(info)->ai_canonname;
            }

            // Set the domain name if the FQDN is prefixed with the hostname
            if (boost::starts_with(result.fqdn, result.hostname + ".")) {
                result.domain = result.fqdn.substr(result.hostname.size() + 1);
            }
        }

        // If no domain, look it up based on resolv.conf
        if (result.domain.empty()) {
            string search;
            lth_file::each_line("/etc/resolv.conf", [&](string& line) {
                vector<boost::iterator_range<string::iterator>> parts;
                boost::split(parts, line, boost::is_space(), boost::token_compress_on);
                if (parts.size() < 2) {
                    return true;
                }
                if (parts[0] == boost::as_literal("domain")) {
                    // Treat the first domain entry as the domain
                    result.domain.assign(parts[1].begin(), parts[1].end());
                    return false;
                }
                if (search.empty() && parts[0] == boost::as_literal("search")) {
                    // Found a "search" entry, but keep looking for other domain entries
                    // We use the first search domain as the domain.
                    search.assign(parts[1].begin(), parts[1].end());
                    return true;
                }
                return true;
            });
            if (result.domain.empty()) {
                result.domain = move(search);
            }
        }
        return result;
    }

}}}  // namespace facter::facts::posix
