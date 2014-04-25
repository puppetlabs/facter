#include <facter/facts/posix/operating_system_resolver.hpp>
#include <facter/facts/posix/os.hpp>
#include <facter/facts/posix/os_family.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/facts/fact_map.hpp>
#include <map>

using namespace std;

namespace facter { namespace facts { namespace posix {

    void operating_system_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all operating system related facts
        resolve_operating_system(facts);
        resolve_os_family(facts);
        resolve_operating_system_release(facts);
        resolve_operating_system_major_release(facts);
    }

    void operating_system_resolver::resolve_operating_system(fact_map& facts)
    {
        // Default to the same value as the kernel
        auto kernel = facts.get<string_value>(fact::kernel);
        if (!kernel) {
            return;
        }

        facts.add(fact::operating_system, make_value<string_value>(kernel->value()));
    }

    void operating_system_resolver::resolve_os_family(fact_map& facts)
    {
        // Get the operating system fact
        auto os = facts.get<string_value>(fact::operating_system);
        string value;
        if (os) {
            static map<string, string> systems = {
                { string(os::redhat),                   string(os_family::redhat) },
                { string(os::fedora),                   string(os_family::redhat) },
                { string(os::centos),                   string(os_family::redhat) },
                { string(os::scientific),               string(os_family::redhat) },
                { string(os::scientific_cern),          string(os_family::redhat) },
                { string(os::ascendos),                 string(os_family::redhat) },
                { string(os::cloud_linux),              string(os_family::redhat) },
                { string(os::psbm),                     string(os_family::redhat) },
                { string(os::oracle_linux),             string(os_family::redhat) },
                { string(os::oracle_vm_linux),          string(os_family::redhat) },
                { string(os::oracle_enterprise_linux),  string(os_family::redhat) },
                { string(os::amazon),                   string(os_family::redhat) },
                { string(os::xen_server),               string(os_family::redhat) },
                { string(os::linux_mint),               string(os_family::debian) },
                { string(os::ubuntu),                   string(os_family::debian) },
                { string(os::debian),                   string(os_family::debian) },
                { string(os::suse_enterprise_server),   string(os_family::suse) },
                { string(os::suse_enterprise_desktop),  string(os_family::suse) },
                { string(os::open_suse),                string(os_family::suse) },
                { string(os::suse),                     string(os_family::suse) },
                { string(os::solaris),                  string(os_family::solaris) },
                { string(os::nexenta),                  string(os_family::solaris) },
                { string(os::omni),                     string(os_family::solaris) },
                { string(os::open_indiana),             string(os_family::solaris) },
                { string(os::smart),                    string(os_family::solaris) },
                { string(os::gentoo),                   string(os_family::gentoo) },
                { string(os::archlinux),                string(os_family::archlinux) },
                { string(os::mandrake),                 string(os_family::mandrake) },
                { string(os::mandriva),                 string(os_family::mandrake) },
                { string(os::mageia),                   string(os_family::mandrake) },
            };
            auto const& it = systems.find(os->value());
            if (it != systems.end()) {
                value = it->second;
            }
        }

        if (value.empty()) {
            // Default to the same value as the kernel
            auto kernel = facts.get<string_value>(fact::kernel);
            if (!kernel) {
                return;
            }
            value = kernel->value();
        }
        facts.add(fact::os_family, make_value<string_value>(move(value)));
    }

    void operating_system_resolver::resolve_operating_system_release(fact_map& facts)
    {
        // Default to the same value as the kernelrelease fact
        auto release = facts.get<string_value>(fact::kernel_release);
        if (!release) {
            return;
        }

        facts.add(fact::operating_system_release, make_value<string_value>(release->value()));
    }

}}}  // namespace facter::facts::posix
