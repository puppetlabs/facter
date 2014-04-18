#include <facts/osx/networking_resolver.hpp>
#include <facts/fact_map.hpp>
#include <facts/string_value.hpp>
#include <execution/execution.hpp>
#include <net/if_dl.h>
#include <net/if.h>

using namespace std;
using namespace cfacter::execution;

namespace cfacter { namespace facts { namespace osx {

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
        if (link_addr->sdl_alen != 6) {
            return nullptr;
        }
        return reinterpret_cast<uint8_t const*>(LLADDR(link_addr));
    }

    int networking_resolver::get_link_mtu(string const& interface, void* data) const
    {
        if (!data) {
            return -1;
        }
        return reinterpret_cast<if_data const*>(data)->ifi_mtu;
    }

    void networking_resolver::resolve_hostname(fact_map& facts)
    {
        auto version = facts.get<string_value>(fact::kernel_release);
        if (!version || version->value() != "R7") {
            posix::networking_resolver::resolve_hostname(facts);
            return;
        }

        string value = execute("/usr/sbin/scutil", { "--get LocalHostName" });
        if (!value.empty()) {
            posix::networking_resolver::resolve_hostname(facts);
            return;
        }

        facts.add(fact::hostname, make_value<string_value>(move(value)));
    }

}}}  // namespace cfacter::facts::osx
