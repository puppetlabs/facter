#include <execution/execution.hpp>
#include <facts/linux/operating_system_resolver.hpp>
#include <facts/linux/lsb_resolver.hpp>
#include <facts/linux/release_file.hpp>
#include <facts/posix/os.hpp>
#include <facts/string_value.hpp>
#include <facts/fact_map.hpp>
#include <util/string.hpp>
#include <util/file.hpp>
#include <re2/re2.h>
#include <map>

using namespace std;
using namespace cfacter::util;
using namespace cfacter::execution;
using namespace cfacter::facts::posix;

namespace cfacter { namespace facts { namespace linux {

    void operating_system_resolver::resolve_operating_system(fact_map& facts)
    {
        auto dist_id = facts.get<string_value>(fact::lsb_dist_id);

        // Start by checking for Cumulus Linux
        string value = check_cumulus_linux();

        // Check for Debian next
        if (value.empty()) {
            value = check_debian_linux(dist_id);
        }

        // Check for Oracle Enterprise Linux next
        if (value.empty()) {
            value = check_oracle_linux();
        }

        // Check for RedHat next
        if (value.empty()) {
            value = check_redhat_linux();
        }

        // Check for SuSE next
        if (value.empty()) {
            value = check_suse_linux();
        }

        // Check for some other Linux next
        if (value.empty()) {
            value = check_other_linux();
        }

        // If no value, default to the base implementation
        if (value.empty()) {
            posix::operating_system_resolver::resolve_operating_system(facts);
            return;
        }

        // Add the fact
        facts.add(posix::fact::operating_system, make_value<string_value>(value));
    }

    void operating_system_resolver::resolve_operating_system_release(fact_map& facts)
    {
        auto operating_system = facts.get<string_value>(posix::fact::operating_system);
        if (!operating_system) {
            // Use the base implementation
            posix::operating_system_resolver::resolve_operating_system_release(facts);
            return;
        }

        // Map of release files that contain a "release X.X.X" on the first line
        static map<string, string> release_files = {
            { string(os::centos),                   string(release_file::redhat) },
            { string(os::redhat),                   string(release_file::redhat) },
            { string(os::scientific),               string(release_file::redhat) },
            { string(os::scientific_cern),          string(release_file::redhat) },
            { string(os::ascendos),                 string(release_file::redhat) },
            { string(os::cloud_linux),              string(release_file::redhat) },
            { string(os::psbm),                     string(release_file::redhat) },
            { string(os::xen_server),               string(release_file::redhat) },
            { string(os::fedora),                   string(release_file::fedora) },
            { string(os::meego),                    string(release_file::meego) },
            { string(os::oracle_linux),             string(release_file::oracle_linux) },
            { string(os::oracle_enterprise_linux),  string(release_file::oracle_enterprise_linux) },
            { string(os::oracle_vm_linux),          string(release_file::oracle_vm_linux) },
        };

        string value;
        auto it = release_files.find(operating_system->value());
        if (it != release_files.end()) {
            string contents = file::read_first_line(it->second);
            if (ends_with(contents, "(Rawhide)")) {
                value = "Rawhide";
            } else {
                RE2::PartialMatch(contents, "release (\\d[\\d.]*)", &value);
            }
        }

        // Debian uses the entire contents of the release file as the version
        if (value.empty() && operating_system->value() == os::debian) {
            value = rtrim(file::read(release_file::debian));
        }

        // Alpine uses the entire contents of the release file as the version
        if (value.empty() && operating_system->value() == os::alpine) {
            value = rtrim(file::read(release_file::alpine));
        }

        // Check for SuSE related distros, read the release file
        if (value.empty() && (
            operating_system->value() == os::suse ||
            operating_system->value() == os::suse_enterprise_server ||
            operating_system->value() == os::suse_enterprise_desktop ||
            operating_system->value() == os::open_suse)) {
            string contents = file::read(release_file::suse);
            string major;
            string minor;
            if (RE2::PartialMatch(contents, "(?m)^VERSION\\s*=\\s*(\\d+)\\.?(\\d+)?", &major, &minor)) {
                // Check that we have a minor version; if not, use the patch level
                if (minor.empty()) {
                    if (!RE2::PartialMatch(contents, "(?m)^PATCHLEVEL\\s*=\\s*(\\d+)", &minor)) {
                        minor = "0";
                    }
                }
                value = major + "." + minor;
            } else {
                value = "unknown";
            }
        }

        // Read version files of particular operating systems
        if (value.empty()) {
            const char* file = nullptr;
            string regex;
            if (operating_system->value() == os::ubuntu) {
                file = release_file::lsb;
                regex = "(?m)^DISTRIB_RELEASE=(\\d+\\.\\d+)(?:\\.\\d+)*";
            } else if (operating_system->value() == os::slackware) {
                file = release_file::slackware;
                regex = "Slackware ([0-9.]+)";
            } else if (operating_system->value() == os::mageia) {
                file = release_file::mageia;
                regex = "Mageia release ([0-9.]+)";
            } else if (operating_system->value() == os::bluewhite) {
                file = release_file::bluewhite;
                regex = "(?m)^\\s*\\w+\\s+(\\d+\\.\\d+)";
            } else if (operating_system->value() == os::slack_amd64) {
                file = release_file::slack_amd64;
                regex = "(?m)^\\s*\\w+\\s+(\\d+\\.\\d+)";
            } else if (operating_system->value() == os::cumulus) {
                file = release_file::os;
                regex = "(?m)^VERSION_ID\\s*=\\s*(\\d+\\.\\d+\\.\\d+)";
            } else if (operating_system->value() == os::linux_mint) {
                file = release_file::linux_mint_info;
                regex = "(?m)^RELEASE=(\\d+)";
            } else if (operating_system->value() == os::openwrt) {
                file = release_file::openwrt_version;
                regex = "(?m)^(\\d+\\.\\d+.*)";
            }
            if (file) {
                string contents = file::read(file);
                RE2::PartialMatch(contents, regex, &value);
            }
        }

        // For VMware ESX, execute the vmware tool
        if (value.empty() && operating_system->value() == os::vmware_esx) {
            string output = execute("vmware", { "-v" });
            RE2::PartialMatch(output, "VMware ESX .*?(\\d.*)", &value);
        }

        // For Amazon, use the lsbdistrelease fact
        if (value.empty() && operating_system->value() == os::amazon) {
            auto release = facts.get<string_value>(fact::lsb_dist_release);
            if (release) {
                facts.add(posix::fact::operating_system_release, make_value<string_value>(release->value()));
                return;
            }
        }

        // Use the base implementation if we have no value
        if (value.empty()) {
            posix::operating_system_resolver::resolve_operating_system_release(facts);
            return;
        }

        facts.add(posix::fact::operating_system_release, make_value<string_value>(std::move(value)));
    }

    void operating_system_resolver::resolve_operating_system_major_release(fact_map& facts) {
        auto operating_system = facts.get<string_value>(posix::fact::operating_system);
        auto os_release = facts.get<string_value>(posix::fact::operating_system_release);

        if (!operating_system ||
            !os_release || !(
            operating_system->value() == os::amazon ||
            operating_system->value() == os::centos ||
            operating_system->value() == os::cloud_linux ||
            operating_system->value() == os::debian ||
            operating_system->value() == os::fedora ||
            operating_system->value() == os::oracle_enterprise_linux ||
            operating_system->value() == os::oracle_vm_linux ||
            operating_system->value() == os::redhat ||
            operating_system->value() == os::scientific ||
            operating_system->value() == os::scientific_cern ||
            operating_system->value() == os::cumulus))
        {
            // Use the base implementation
            posix::operating_system_resolver::resolve_operating_system_major_release(facts);
            return;
        }

        string value = os_release->value();
        auto pos = value.find('.');
        if (pos != string::npos) {
            value = value.substr(0, pos);
        }
        facts.add(posix::fact::operating_system_major_release, make_value<string_value>(std::move(value)));
    }

    string operating_system_resolver::check_cumulus_linux()
    {
        // Check for Cumulus Linux in a generic os-release file
        if (file::exists(release_file::os)) {
            string contents = trim(file::read(release_file::os));
            string release;
            if (RE2::PartialMatch(contents, "(?m)^NAME=[\"']?(.+?)[\"']?$", &release)) {
                RE2::GlobalReplace(&release, "[^a-zA-Z]", "");
                if (release == os::cumulus) {
                    return release;
                }
            }
        }
        return string();
    }

    string operating_system_resolver::check_debian_linux(string_value const* dist_id)
    {
        // Check for Debian variants
        if (file::exists(release_file::debian)) {
            if (dist_id) {
                if (dist_id->value() == os::ubuntu || dist_id->value() == os::linux_mint) {
                    return dist_id->value();
                }
            }
            return os::debian;
        }
        return string();
    }

    string operating_system_resolver::check_oracle_linux()
    {
        if (file::exists(release_file::oracle_enterprise_linux)) {
            if (file::exists(release_file::oracle_vm_linux)) {
                return os::oracle_vm_linux;
            }
            return os::oracle_enterprise_linux;
        }
        return string();
    }

    string operating_system_resolver::check_redhat_linux()
    {
        if (file::exists(release_file::redhat)) {
            static map<string, string> regexs {
                { "(?i)centos",                         string(os::centos) },
                { "(?i)scientific linux CERN",          string(os::scientific_cern) },
                { "(?i)scientific linux release",       string(os::scientific) },
                { "(?im)^cloudlinux",                    string(os::cloud_linux) },
                { "(?i)Ascendos",                       string(os::ascendos) },
                { "(?im)^XenServer",                     string(os::xen_server) },
                { "XCP",                                string(os::zen_cloud_platform) },
                { "(?im)^Parallels Server Bare Metal",   string(os::psbm) },
                { "(?m)^Fedora release",                    string(os::fedora) },
            };

            string contents = trim(file::read(release_file::redhat));
            for (auto const& kvp : regexs) {
                if (RE2::PartialMatch(contents, kvp.first)) {
                    return kvp.second;
                }
            }
            return os::redhat;
        }
        return string();
    }

    string operating_system_resolver::check_suse_linux()
    {
        if (file::exists(release_file::suse)) {
            static map<string, string> regexs {
                { "(?im)^SUSE LINUX Enterprise Server",  string(os::suse_enterprise_server) },
                { "(?im)^SUSE LINUX Enterprise Desktop", string(os::suse_enterprise_desktop) },
                { "(?im)^openSUSE",                      string(os::open_suse) },
            };

            string contents = trim(file::read(release_file::suse));
            for (auto const& kvp : regexs) {
                if (RE2::PartialMatch(contents, kvp.first)) {
                    return kvp.second;
                }
            }
            return os::suse;
        }
        return string();
    }

    string operating_system_resolver::check_other_linux()
    {
        static map<string, string> files {
            { string(release_file::openwrt),        string(os::openwrt) },
            { string(release_file::gentoo),         string(os::gentoo) },
            { string(release_file::mandriva),       string(os::mandriva) },
            { string(release_file::mandrake),       string(os::mandrake) },
            { string(release_file::meego),          string(os::meego) },
            { string(release_file::archlinux),      string(os::archlinux) },
            { string(release_file::oracle_linux),   string(os::oracle_linux) },
            { string(release_file::vmware_esx),     string(os::vmware_esx) },
            { string(release_file::bluewhite),      string(os::bluewhite) },
            { string(release_file::slack_amd64),    string(os::slack_amd64) },
            { string(release_file::slackware),      string(os::slackware) },
            { string(release_file::alpine),         string(os::alpine) },
            { string(release_file::mageia),         string(os::mageia) },
            { string(release_file::amazon),         string(os::amazon) },
        };

        for (auto const& kvp : files) {
            if (file::exists(kvp.first)) {
                return kvp.second;
            }
        }
        return string();
    }

}}}  // namespace cfacter::facts::linux
