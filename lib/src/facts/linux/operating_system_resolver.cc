#include <facter/facts/linux/operating_system_resolver.hpp>
#include <facter/facts/linux/release_file.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/file.hpp>
#include <facter/util/regex.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <map>
#include <vector>
#include <tuple>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace boost::filesystem;
namespace bs = boost::system;

namespace facter { namespace facts { namespace linux {

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = posix::operating_system_resolver::collect_data(facts);

        // Convert the hardware model value depending on distro
        // For certain distros, use "amd64" for x86_64
        if (result.hardware == "x86_64" && (
             result.name == os::debian ||
             result.name == os::gentoo ||
             result.name == os::kfreebsd ||
             result.name == os::ubuntu)) {
            result.hardware = "amd64";
        } else if (re_search(result.hardware, "i[3456]86|pentium")) {
            // For 32-bit, use "x86" for Gentoo and "i386" for everyone else
            if (result.name == os::gentoo) {
                result.hardware = "x86";
            } else {
                result.hardware = "i386";
            }
        }

        // Populate distro info
        execution::each_line("lsb_release", {"-a"}, [&](string& line) {
            string* variable = nullptr;
            size_t offset = 0;
            if (boost::starts_with(line, "LSB Version:")) {
                variable = &result.specification_version;
                offset = 12;
            } else if (boost::starts_with(line, "Distributor ID:")) {
                variable = &result.distro.id;
                offset = 15;
            } else if (boost::starts_with(line, "Description:")) {
                variable = &result.distro.description;
                offset = 12;
            } else if (boost::starts_with(line, "Codename:")) {
                variable = &result.distro.codename;
                offset = 9;
            } else if (boost::starts_with(line, "Release:")) {
                variable = &result.distro.release;
                offset = 8;
            }
            if (!variable) {
                return true;
            }
            *variable = line.substr(offset);
            boost::trim(*variable);
            return true;
        });

        auto name = get_name(result.distro.id);
        if (!name.empty()) {
            result.name = move(name);
        }

        auto release = get_release(result.name, result.distro.release);
        if (!release.empty()) {
            result.release = move(release);
        }

        return result;
    }

    string operating_system_resolver::get_name(string const& distro_id)
    {
        // Start by checking for Cumulus Linux or CoreOS
        string value = check_os_release_linux();
        if (!value.empty()) {
            return value;
        }

        // Check for Debian next
        value = check_debian_linux(distro_id);
        if (!value.empty()) {
            return value;
        }

        // Check for Oracle Enterprise Linux next
        value = check_oracle_linux();
        if (!value.empty()) {
            return value;
        }

        // Check for RedHat next
        value = check_redhat_linux();
        if (!value.empty()) {
            return value;
        }

        // Check for SuSE next
        value = check_suse_linux();
        if (!value.empty()) {
            return value;
        }

        // Check for some other Linux last
        return check_other_linux();
    }

    string operating_system_resolver::get_release(string const& name, string const& distro_release)
    {
        // Map of release files that contain a "release X.X.X" on the first line
        static map<string, string> const release_files = {
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
        auto it = release_files.find(name);
        if (it != release_files.end()) {
            string contents = file::read_first_line(it->second);
            if (boost::ends_with(contents, "(Rawhide)")) {
                value = "Rawhide";
            } else {
                re_search(contents, "release (\\d[\\d.]*)", &value);
            }
        }

        // Debian uses the entire contents of the release file as the version
        if (value.empty() && name == os::debian) {
            value = file::read(release_file::debian);
            boost::trim_right(value);
        }

        // Alpine uses the entire contents of the release file as the version
        if (value.empty() && name == os::alpine) {
            value = file::read(release_file::alpine);
            boost::trim_right(value);
        }

        // Check for SuSE related distros, read the release file
        if (value.empty() && (
                name == os::suse ||
                name == os::suse_enterprise_server ||
                name == os::suse_enterprise_desktop ||
                name == os::open_suse)) {
            string contents = file::read(release_file::suse);
            string major;
            string minor;
            if (re_search(contents, "(?m)^VERSION\\s*=\\s*(\\d+)\\.?(\\d+)?", &major, &minor)) {
                // Check that we have a minor version; if not, use the patch level
                if (minor.empty()) {
                    if (!re_search(contents, "(?m)^PATCHLEVEL\\s*=\\s*(\\d+)", &minor)) {
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
            if (name == os::ubuntu) {
                file = release_file::lsb;
                regex = "(?m)^DISTRIB_RELEASE=(\\d+\\.\\d+)(?:\\.\\d+)*";
            } else if (name == os::slackware) {
                file = release_file::slackware;
                regex = "Slackware ([0-9.]+)";
            } else if (name == os::mageia) {
                file = release_file::mageia;
                regex = "Mageia release ([0-9.]+)";
            } else if (name == os::cumulus || name == os::coreos) {
                file = release_file::os;
                regex = "(?m)^VERSION_ID\\s*=\\s*(\\d+\\.\\d+\\.\\d+)";
            } else if (name == os::linux_mint) {
                file = release_file::linux_mint_info;
                regex = "(?m)^RELEASE=(\\d+)";
            } else if (name == os::openwrt) {
                file = release_file::openwrt_version;
                regex = "(?m)^(\\d+\\.\\d+.*)";
            }
            if (file) {
                string contents = file::read(file);
                re_search(contents, regex, &value);
            }
        }

        // For VMware ESX, execute the vmware tool
        if (value.empty() && name == os::vmware_esx) {
            auto result = execute("vmware", { "-v" });
            if (result.first) {
                re_search(result.second, "VMware ESX .*?(\\d.*)", &value);
            }
        }

        // For Amazon, use the distro release
        if (value.empty() && name == os::amazon) {
            return distro_release;
        }

        return value;
    }

    tuple<string, string> operating_system_resolver::parse_release(string const& name, string const& release) const
    {
        if (name != os::ubuntu) {
            return resolvers::operating_system_resolver::parse_release(name, release);
        }

        string major, minor;
        re_search(release, "(\\d+\\.\\d*)\\.?(\\d*)", &major, &minor);
        return make_tuple(move(major), move(minor));
    }

    string operating_system_resolver::check_os_release_linux()
    {
        // Check for NAME in /etc/os-release
        // Both cfacter and ruby facter should use the same field.
        bs::error_code ec;
        if (is_regular_file(release_file::os, ec)) {
            string contents = file::read(release_file::os);
            boost::trim(contents);

            string release;
            if (re_search(contents, "(?m)^NAME=[\"']?(.+?)[\"']?$", &release)) {
                if (release == "Cumulus Linux") {
                    return os::cumulus;
                } else if (release == "CoreOS") {
                    return os::coreos;
                }
            }
        }
        return {};
    }

    string operating_system_resolver::check_debian_linux(string const& distro_id)
    {
        // Check for Debian variants
        bs::error_code ec;
        if (is_regular_file(release_file::debian, ec)) {
            if (distro_id == os::ubuntu || distro_id == os::linux_mint) {
                return distro_id;
            }
            return os::debian;
        }
        return {};
    }

    string operating_system_resolver::check_oracle_linux()
    {
        bs::error_code ec;
        if (is_regular_file(release_file::oracle_enterprise_linux, ec)) {
            if (is_regular_file(release_file::oracle_vm_linux, ec)) {
                return os::oracle_vm_linux;
            }
            return os::oracle_enterprise_linux;
        }
        return {};
    }

    string operating_system_resolver::check_redhat_linux()
    {
        bs::error_code ec;
        if (is_regular_file(release_file::redhat, ec)) {
            static vector<tuple<string, string>> const regexs {
                make_tuple("(?i)centos",                        string(os::centos)),
                make_tuple("(?i)scientific linux CERN",         string(os::scientific_cern)),
                make_tuple("(?i)scientific linux release",      string(os::scientific)),
                make_tuple("(?im)^cloudlinux",                  string(os::cloud_linux)),
                make_tuple("(?i)Ascendos",                      string(os::ascendos)),
                make_tuple("(?im)^XenServer",                   string(os::xen_server)),
                make_tuple("XCP",                               string(os::zen_cloud_platform)),
                make_tuple("(?im)^Parallels Server Bare Metal", string(os::psbm)),
                make_tuple("(?m)^Fedora release",               string(os::fedora)),
            };

            string contents = file::read(release_file::redhat);
            boost::trim(contents);
            for (auto const& regex : regexs) {
                if (re_search(contents, get<0>(regex))) {
                    return get<1>(regex);
                }
            }
            return os::redhat;
        }
        return {};
    }

    string operating_system_resolver::check_suse_linux()
    {
        bs::error_code ec;
        if (is_regular_file(release_file::suse, ec)) {
            static vector<tuple<string, string>> const regexs {
                make_tuple("(?im)^SUSE LINUX Enterprise Server",  string(os::suse_enterprise_server)),
                make_tuple("(?im)^SUSE LINUX Enterprise Desktop", string(os::suse_enterprise_desktop)),
                make_tuple("(?im)^openSUSE",                      string(os::open_suse)),
            };

            string contents = file::read(release_file::suse);
            boost::trim(contents);
            for (auto const& regex : regexs) {
                if (re_search(contents, get<0>(regex))) {
                    return get<1>(regex);
                }
            }
            return os::suse;
        }
        return {};
    }

    string operating_system_resolver::check_other_linux()
    {
        static vector<tuple<string, string>> const files {
            make_tuple(string(release_file::openwrt),        string(os::openwrt)),
            make_tuple(string(release_file::gentoo),         string(os::gentoo)),
            make_tuple(string(release_file::mandriva),       string(os::mandriva)),
            make_tuple(string(release_file::mandrake),       string(os::mandrake)),
            make_tuple(string(release_file::meego),          string(os::meego)),
            make_tuple(string(release_file::archlinux),      string(os::archlinux)),
            make_tuple(string(release_file::oracle_linux),   string(os::oracle_linux)),
            make_tuple(string(release_file::vmware_esx),     string(os::vmware_esx)),
            make_tuple(string(release_file::slackware),      string(os::slackware)),
            make_tuple(string(release_file::alpine),         string(os::alpine)),
            make_tuple(string(release_file::mageia),         string(os::mageia)),
            make_tuple(string(release_file::amazon),         string(os::amazon)),
        };

        for (auto const& file : files) {
            bs::error_code ec;
            if (is_regular_file(get<0>(file), ec)) {
                return get<1>(file);
            }
        }
        return {};
    }
}}}  // namespace facter::facts::linux
