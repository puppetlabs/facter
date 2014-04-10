#include <facts/linux/operating_system_resolver.hpp>
#include <facts/linux/lsb_resolver.hpp>
#include <facts/string_value.hpp>
#include <facts/fact_map.hpp>
#include <util/string.hpp>
#include <util/file.hpp>
#include <re2/re2.h>
#include <map>

using namespace std;
using namespace cfacter::util;

namespace cfacter { namespace facts { namespace linux {

    void operating_system_resolver::resolve_operating_system(fact_map& facts)
    {
        auto dist_id = facts.get_value<string_value>(lsb_resolver::lsb_dist_id_name);

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
        facts.add_fact(fact(operating_system_name, make_value<string_value>(value)));
    }

    string operating_system_resolver::check_cumulus_linux()
    {
        // Check for Cumulus Linux
        if (file::exists("/etc/os-release")) {
            string contents = trim(file::read("/etc/os-release"));
            string release;
            if (RE2::FullMatch(contents, "^NAME=[\"']?(.+?)[\"']?$", &release)) {
                RE2::GlobalReplace(&release, "[^a-zA-Z]", "");
                if (release == "CumulusLinux") {
                    return "CumulusLinux";
                }
            }
        }
        return string();
    }

    string operating_system_resolver::check_debian_linux(string_value const* dist_id)
    {
        // Check for Debian variants
        if (file::exists("/etc/debian_version")) {
            if (dist_id) {
                if (dist_id->value() == "Ubuntu") {
                    return "Ubuntu";
                }
                if (dist_id->value() == "LinuxMint") {
                    return "LinuxMint";
                }
            }
            return "Debian";
        }
        return string();
    }

    string operating_system_resolver::check_oracle_linux()
    {
        if (file::exists("/etc/enterprise-release")) {
            if (file::exists("/etc/ovs-release")) {
                return "OVS";
            }
            return "OEL";
        }
        return string();
    }

    string operating_system_resolver::check_redhat_linux()
    {
        if (file::exists("/etc/redhat-release")) {
            static map<string, string> regexs {
                { "(?i)centos", "CentOS" },
                { "(?i)scientific linux CERN", "SLC" },
                { "(?i)scientific linux release", "Scientific" },
                { "(?i)^cloudlinux", "CloudLinux" },
                { "(?i)Ascendos", "Ascendos" },
                { "(?i)^XenServer", "XenServer" },
                { "XCP", "XCP" },
                { "(?i)^Parallels Server Bare Metal", "PSBM" },
                { "^Fedora release", "Fedora" },
            };

            string contents = trim(file::read("/etc/redhat-release"));
            for (auto const& kvp : regexs) {
                if (RE2::PartialMatch(contents, kvp.first)) {
                    return kvp.second;
                }
            }
            return "RedHat";
        }
        return string();
    }

    string operating_system_resolver::check_suse_linux()
    {
        if (file::exists("/etc/SuSE-release")) {
            static map<string, string> regexs {
                { "(?i)^SUSE LINUX Enterprise Server", "SLES" },
                { "(?i)^SUSE LINUX Enterprise Desktop", "SLED" },
                { "(?i)^openSUSE", "OpenSuSE" },
            };

            string contents = trim(file::read("/etc/SuSE-release"));
            for (auto const& kvp : regexs) {
                if (RE2::PartialMatch(contents, kvp.first)) {
                    return kvp.second;
                }
            }
            return "SuSE";
        }
        return string();
    }

    string operating_system_resolver::check_other_linux()
    {
        static map<string, string> files {
            { "/etc/openwrt_release", "OpenWrt" },
            { "/etc/gentoo-release", "Gentoo" },
            { "/etc/mandriva-release", "Mandriva" },
            { "/etc/mandrake-release", "Mandrake" },
            { "/etc/meego-release", "MeeGo" },
            { "/etc/arch-release", "Archlinux" },
            { "/etc/oracle-release", "OracleLinux" },
            { "/etc/vmware-release", "VMWareESX" },
            { "/etc/bluewhite64-version", "Bluewhite64" },
            { "/etc/slamd64-version", "Slamd64" },
            { "/etc/slackware-version", "Slackware" },
            { "/etc/alpine-release", "Alpine" },
            { "/etc/mageia-release", "Mageia" },
            { "/etc/system-release", "Amazon" },
        };

        for (auto const& kvp : files) {
            if (file::exists(kvp.first)) {
                return kvp.second;
            }
        }
        return string();
    }

}}}  // namespace cfacter::facts::linux
