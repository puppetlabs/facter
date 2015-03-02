#include <facter/facts/resolvers/operating_system_resolver.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/os_family.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    operating_system_resolver::operating_system_resolver() :
        resolver(
            "operating system",
            {
                fact::os,
                fact::operating_system,
                fact::os_family,
                fact::operating_system_release,
                fact::operating_system_major_release,
                fact::hardware_model,
                fact::architecture,
                fact::lsb_dist_id,
                fact::lsb_dist_release,
                fact::lsb_dist_codename,
                fact::lsb_dist_description,
                fact::lsb_dist_major_release,
                fact::lsb_dist_minor_release,
                fact::lsb_release,
                fact::macosx_buildversion,
                fact::macosx_productname,
                fact::macosx_productversion,
                fact::macosx_productversion_major,
                fact::macosx_productversion_minor,
                fact::windows_system32,
                fact::selinux,
                fact::selinux_enforced,
                fact::selinux_policyversion,
                fact::selinux_current_mode,
                fact::selinux_config_mode,
                fact::selinux_config_policy,
            })
    {
    }

    void operating_system_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        auto os = make_value<map_value>();
        auto family = determine_os_family(facts, data.name);
        if (!family.empty()) {
            facts.add(fact::os_family, make_value<string_value>(family, true));
            os->add("family", make_value<string_value>(move(family)));
        }

        if (!data.release.empty()) {
            auto value = make_value<map_value>();

            string major, minor;
            tie(major, minor) = parse_release(data.name, data.release);

            if (!major.empty()) {
                facts.add(fact::operating_system_major_release, make_value<string_value>(major, true));
                value->add("major", make_value<string_value>(move(major)));
            }
            if (!minor.empty()) {
                value->add("minor", make_value<string_value>(move(minor)));
            }

            facts.add(fact::operating_system_release, make_value<string_value>(data.release, true));
            value->add("full", make_value<string_value>(move(data.release)));

            os->add("release", move(value));
        }

        // Add the OS hardware and architecture facts
        if (!data.hardware.empty()) {
            facts.add(fact::hardware_model, make_value<string_value>(data.hardware, true));
            os->add("hardware", make_value<string_value>(move(data.hardware)));
        }
        if (!data.architecture.empty()) {
            facts.add(fact::architecture, make_value<string_value>(data.architecture, true));
            os->add("architecture", make_value<string_value>(move(data.architecture)));
        }

        // Add distro facts
        auto distro = make_value<map_value>();
        if (!data.distro.id.empty()) {
            facts.add(fact::lsb_dist_id, make_value<string_value>(data.distro.id, true));
            distro->add("id", make_value<string_value>(move(data.distro.id)));
        }
        if (!data.distro.codename.empty()) {
            facts.add(fact::lsb_dist_codename, make_value<string_value>(data.distro.codename, true));
            distro->add("codename", make_value<string_value>(move(data.distro.codename)));
        }
        if (!data.distro.description.empty()) {
            facts.add(fact::lsb_dist_description, make_value<string_value>(data.distro.description, true));
            distro->add("description", make_value<string_value>(move(data.distro.description)));
        }
        if (!data.distro.release.empty()) {
            auto value = make_value<map_value>();

            string major, minor;
            tie(major, minor) = parse_release(data.name, data.distro.release);

            if (major.empty()) {
                major = data.distro.release;
            }
            facts.add(fact::lsb_dist_major_release, make_value<string_value>(major, true));
            value->add("major", make_value<string_value>(move(major)));

            if (!minor.empty()) {
                facts.add(fact::lsb_dist_minor_release, make_value<string_value>(minor, true));
                value->add("minor", make_value<string_value>(move(minor)));
            }

            facts.add(fact::lsb_dist_release, make_value<string_value>(data.distro.release, true));
            value->add("full", make_value<string_value>(move(data.distro.release)));
            distro->add("release", move(value));
        }
        if (!data.specification_version.empty()) {
            facts.add(fact::lsb_release, make_value<string_value>(data.specification_version, true));
            distro->add("specification", make_value<string_value>(move(data.specification_version)));
        }

        // Add the name last since the above release parsing is dependent on it
        if (!data.name.empty()) {
            facts.add(fact::operating_system, make_value<string_value>(data.name, true));
            os->add("name", make_value<string_value>(move(data.name)));
        }

        if (!distro->empty()) {
             os->add("distro", move(distro));
        }

        // Populate OSX-specific data
        auto macosx = make_value<map_value>();
        if (!data.osx.product.empty()) {
            facts.add(fact::macosx_productname, make_value<string_value>(data.osx.product, true));
            macosx->add("product", make_value<string_value>(move(data.osx.product)));
        }
        if (!data.osx.build.empty()) {
            facts.add(fact::macosx_buildversion, make_value<string_value>(data.osx.build, true));
            macosx->add("build", make_value<string_value>(move(data.osx.build)));
        }

        if (!data.osx.version.empty()) {
            // Look for the last '.' for major/minor
            auto version = make_value<map_value>();
            auto pos = data.osx.version.rfind('.');
            if (pos != string::npos) {
                string major = data.osx.version.substr(0, pos);
                string minor = data.osx.version.substr(pos + 1);

                // If the major doesn't have a '.', treat the entire version as the major
                // and use a minor of "0"
                if (major.find('.') == string::npos) {
                    major = data.osx.version;
                    minor = "0";
                }

                if (!major.empty()) {
                    facts.add(fact::macosx_productversion_major, make_value<string_value>(major, true));
                    version->add("major", make_value<string_value>(move(major)));
                }
                if (!minor.empty()) {
                    facts.add(fact::macosx_productversion_minor, make_value<string_value>(minor, true));
                    version->add("minor", make_value<string_value>(move(minor)));
                }
            }
            facts.add(fact::macosx_productversion, make_value<string_value>(data.osx.version, true));
            version->add("full", make_value<string_value>(move(data.osx.version)));
            macosx->add("version", move(version));
        }

        if (!macosx->empty()) {
            os->add("macosx", move(macosx));
        }

        // Populate Windows-specific data
        auto windows = make_value<map_value>();
        if (!data.win.system32.empty()) {
            facts.add(fact::windows_system32, make_value<string_value>(data.win.system32, true));
            windows->add("system32", make_value<string_value>(move(data.win.system32)));
        }

        if (!windows->empty()) {
            os->add("windows", move(windows));
        }

        if (data.selinux.supported) {
            auto selinux = make_value<map_value>();
            facts.add(fact::selinux, make_value<boolean_value>(data.selinux.enabled, true));
            selinux->add("enabled", make_value<boolean_value>(data.selinux.enabled));
            if (data.selinux.enabled) {
                facts.add(fact::selinux_enforced, make_value<boolean_value>(data.selinux.enforced, true));
                selinux->add("enforced", make_value<boolean_value>(data.selinux.enforced));
                if (!data.selinux.current_mode.empty()) {
                    facts.add(fact::selinux_current_mode, make_value<string_value>(data.selinux.current_mode, true));
                    selinux->add("current_mode", make_value<string_value>(move(data.selinux.current_mode)));
                }
                if (!data.selinux.config_mode.empty()) {
                    facts.add(fact::selinux_config_mode, make_value<string_value>(data.selinux.config_mode, true));
                    selinux->add("config_mode", make_value<string_value>(move(data.selinux.config_mode)));
                }
                if (!data.selinux.config_policy.empty()) {
                    facts.add(fact::selinux_config_policy, make_value<string_value>(data.selinux.config_policy, true));
                    selinux->add("config_policy", make_value<string_value>(move(data.selinux.config_policy)));
                }
                if (!data.selinux.policy_version.empty()) {
                    facts.add(fact::selinux_policyversion, make_value<string_value>(data.selinux.policy_version, true));
                    selinux->add("policy_version", make_value<string_value>(move(data.selinux.policy_version)));
                }
            }
            os->add("selinux", move(selinux));
        }

        if (!os->empty()) {
            facts.add(fact::os, move(os));
        }
    }

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        data result;

        auto kernel = facts.get<string_value>(fact::kernel);
        if (kernel) {
            result.name = kernel->value();
        }

        auto release = facts.get<string_value>(fact::kernel_release);
        if (release) {
            result.release = release->value();
        }

        return result;
    }

    tuple<string, string> operating_system_resolver::parse_release(string const& name, string const& release) const
    {
        auto pos = release.find('.');
        if (pos != string::npos) {
            auto second = release.find('.', pos + 1);
            return make_tuple(release.substr(0, pos), release.substr(pos + 1, second - (pos + 1)));
        }
        return make_tuple(release, string());
    }

    string operating_system_resolver::determine_os_family(collection& facts, string const& name) const
    {
        if (!name.empty()) {
            static map<string, string> const systems = {
                { string(os::coreos),                   string(os_family::coreos) },
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
                { string(os::cumulus),                  string(os_family::debian) },
                { string(os::suse_enterprise_server),   string(os_family::suse) },
                { string(os::suse_enterprise_desktop),  string(os_family::suse) },
                { string(os::open_suse),                string(os_family::suse) },
                { string(os::suse),                     string(os_family::suse) },
                { string(os::sunos),                    string(os_family::solaris) },
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
                { string(os::windows),                  string(os_family::windows) },
            };
            auto const& it = systems.find(name);
            if (it != systems.end()) {
                return it->second;
            }
        }

        // Default to the same value as the kernel
        auto kernel = facts.get<string_value>(fact::kernel);
        if (!kernel) {
            return {};
        }
        return  kernel->value();
    }

}}}  // namespace facter::facts::resolvers
