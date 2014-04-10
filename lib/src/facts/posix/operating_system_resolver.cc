#include <facts/posix/kernel_resolver.hpp>
#include <facts/posix/operating_system_resolver.hpp>
#include <facts/string_value.hpp>
#include <facts/fact_map.hpp>
#include <map>

using namespace std;

namespace cfacter { namespace facts { namespace posix {

    void operating_system_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all operating system related facts
        resolve_operating_system(facts);
        resolve_os_family(facts);
    }

    void operating_system_resolver::resolve_operating_system(fact_map& facts)
    {
        // Default to the same value as the kernel
        auto kernel = facts.get<string_value>(kernel_resolver::kernel_name);
        if (!kernel) {
            return;
        }

        facts.add(operating_system_name, make_value<string_value>(kernel->value()));
    }

    void operating_system_resolver::resolve_os_family(fact_map& facts)
    {
        // Get the operating system fact
        auto os = facts.get<string_value>(operating_system_name);
        string value;
        if (os) {
            static std::map<string, string> systems = {
                { "RedHat", "RedHat" },
                { "Fedora", "RedHat" },
                { "CentOS", "RedHat" },
                { "Scientific", "RedHat" },
                { "SLC", "RedHat" },
                { "Ascendos", "RedHat" },
                { "CloudLinux", "RedHat" },
                { "PSBM", "RedHat" },
                { "OracleLinux", "RedHat" },
                { "OVS", "RedHat" },
                { "OEL", "RedHat" },
                { "Amazon", "RedHat" },
                { "XenServer", "RedHat" },
                { "LinuxMint", "Debian" },
                { "Ubuntu", "Debian" },
                { "Debian", "Debian" },
                { "SLES", "Suse" },
                { "SLED", "Suse" },
                { "OpenSuSE", "Suse" },
                { "SuSE", "Suse" },
                { "Solaris", "Solaris" },
                { "Nexenta", "Solaris" },
                { "OmniOS", "Solaris" },
                { "OpenIndiana", "Solaris" },
                { "SmartOS", "Solaris" },
                { "Gentoo", "Gentoo" },
                { "Archlinux", "Archlinux" },
                { "Mandrake", "Mandrake" },
                { "Mandriva", "Mandrake" },
                { "Mageia", "Mandrake" },
            };
            auto const& it = systems.find(os->value());
            if (it != systems.end()) {
                value = it->second;
            }
        }

        if (value.empty()) {
            // Default to the same value as the kernel
            auto kernel = facts.get<string_value>(kernel_resolver::kernel_name);
            if (!kernel) {
                return;
            }
            value = kernel->value();
        }
        facts.add(os_family_name, make_value<string_value>(std::move(value)));
    }

}}}  // namespace cfacter::facts::posix
