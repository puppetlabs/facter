#include <internal/facts/resolvers/operating_system_resolver.hpp>
#include <internal/util/versions.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/os.hpp>
#include <leatherman/util/regex.hpp>

using namespace std;
using namespace facter::util;
using namespace leatherman::util;

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
        if (!data.family.empty()) {
            facts.add(fact::os_family, make_value<string_value>(data.family, true));
            os->add("family", make_value<string_value>(move(data.family)));
        }

        if (!data.release.empty()) {
            auto value = make_value<map_value>();

            // When we have no major or minor, do a 'trivial' parse of
            // the release to try to get SOMETHING out of it.
            if (data.minor.empty() && data.major.empty()) {
                 std::tie(data.major, data.minor) = versions::major_minor(data.release);
            }

            if (!data.major.empty()) {
                facts.add(fact::operating_system_major_release, make_value<string_value>(data.major, true));
                value->add("major", make_value<string_value>(move(data.major)));
            }
            if (!data.minor.empty()) {
                value->add("minor", make_value<string_value>(move(data.minor)));
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
            tie(major, minor) = parse_distro(data.name, data.distro.release);

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

        collect_kernel_data(facts, result);
        collect_release_data(facts, result);

        return result;
    }

    void operating_system_resolver::collect_kernel_data(collection& facts, data& result)
    {
        auto kernel = facts.get<string_value>(fact::kernel);
        if (kernel) {
            result.name = kernel->value();
            result.family = kernel->value();
        }
    }

    void operating_system_resolver::collect_release_data(collection& facts, data& result)
    {
        auto release = facts.get<string_value>(fact::kernel_release);
        if (release) {
            result.release = release->value();
        }
    }

    tuple<string, string> operating_system_resolver::parse_distro(string const& name, string const& release)
    {
        // This implementation couples all known formats for lsb_dist and the Linux release versions. If that
        // coupling becomes a problem, we'll probably need to push parsing distro major/minor to inheriting resolvers,
        // as we've done for parsing the release version.
        if (name != os::ubuntu) {
            auto pos = release.find('.');
            if (pos != string::npos) {
                auto second = release.find('.', pos + 1);
                return make_tuple(release.substr(0, pos), release.substr(pos + 1, second - (pos + 1)));
            }
            return make_tuple(release, string());
        }

        string major, minor;
        re_search(release, boost::regex("(\\d+\\.\\d*)\\.?(\\d*)"), &major, &minor);
        return make_tuple(move(major), move(minor));
    }

}}}  // namespace facter::facts::resolvers
