#include <internal/facts/linux/os_linux.hpp>
#include <internal/facts/resolvers/operating_system_resolver.hpp>
#include <internal/util/regex.hpp>
#include <facter/execution/execution.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/os_family.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <vector>

using namespace std;
using namespace facter::execution;
using namespace boost::filesystem;
using namespace facter::util;

namespace bs = boost::system;
namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

    // Return contents of the os-release file
    // http://www.freedesktop.org/software/systemd/man/os-release.html
    map<string, string> os_linux::key_value_file(string file, set<string> const& items)
    {
        map<string, string> values;
        bs::error_code ec;
        if (!items.empty() && is_regular_file(file, ec)) {
            string key, value;
            lth_file::each_line(file, [&](string& line) {
                if (re_search(line, boost::regex("(?m)^(\\w+)=[\"']?(.+?)[\"']?$"), &key, &value)) {
                    if (items.count(key)) {
                        values.insert(make_pair(key, value));
                    }
                }
                return items.size() != values.size();
            });
        }
        return values;
    }

    os_linux::os_linux(std::set<std::string> items, std::string file) :
            _release_info(key_value_file(file, items)) {}

    static string check_debian_linux(string const& distro_id)
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

    static string check_oracle_linux()
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

    static string check_redhat_linux()
    {
        bs::error_code ec;
        if (is_regular_file(release_file::redhat, ec)) {
            static vector<tuple<boost::regex, string>> const regexs {
                make_tuple(boost::regex("(?i)centos"),                        string(os::centos)),
                make_tuple(boost::regex("(?i)scientific linux CERN"),         string(os::scientific_cern)),
                make_tuple(boost::regex("(?i)scientific linux release"),      string(os::scientific)),
                make_tuple(boost::regex("(?im)^cloudlinux"),                  string(os::cloud_linux)),
                make_tuple(boost::regex("(?i)Ascendos"),                      string(os::ascendos)),
                make_tuple(boost::regex("(?im)^XenServer"),                   string(os::xen_server)),
                make_tuple(boost::regex("XCP"),                               string(os::zen_cloud_platform)),
                make_tuple(boost::regex("(?im)^Parallels Server Bare Metal"), string(os::psbm)),
                make_tuple(boost::regex("(?m)^Fedora release"),               string(os::fedora)),
            };

            string contents = lth_file::read(release_file::redhat);
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

    static string check_suse_linux()
    {
        bs::error_code ec;
        if (is_regular_file(release_file::suse, ec)) {
            static vector<tuple<boost::regex, string>> const regexs {
                make_tuple(boost::regex("(?im)^SUSE LINUX Enterprise Server"),  string(os::suse_enterprise_server)),
                make_tuple(boost::regex("(?im)^SUSE LINUX Enterprise Desktop"), string(os::suse_enterprise_desktop)),
                make_tuple(boost::regex("(?im)^openSUSE"),                      string(os::open_suse)),
            };

            string contents = lth_file::read(release_file::suse);
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

    static string check_other_linux()
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
            make_tuple(string(release_file::arista_eos),     string(os::arista_eos)),
        };

        for (auto const& file : files) {
            bs::error_code ec;
            if (is_regular_file(get<0>(file), ec)) {
                return get<1>(file);
            }
        }
        return {};
    }

    string os_linux::get_name(string const& distro_id) const
    {
        // Check for Debian next
        auto value = check_debian_linux(distro_id);
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

    string os_linux::get_family(string const& name) const
    {
        static map<string, string> const systems = {
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
            { string(os::gentoo),                   string(os_family::gentoo) },
            { string(os::archlinux),                string(os_family::archlinux) },
            { string(os::mandrake),                 string(os_family::mandrake) },
            { string(os::mandriva),                 string(os_family::mandrake) },
            { string(os::mageia),                   string(os_family::mandrake) },
        };
        auto const& it = systems.find(name);
        if (it != systems.end()) {
            return it->second;
        }
        return {};
    }

    string os_linux::get_release(string const& name, string const& distro_release) const
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
                { string(os::arista_eos),               string(release_file::arista_eos) },
        };

        string value;
        auto it = release_files.find(name);
        if (it != release_files.end()) {
            string contents;
            if (lth_file::each_line(it->second, [&](string& line) {
                // We only need the first line
                contents = move(line);
                return false;
            })) {
                if (boost::ends_with(contents, "(Rawhide)")) {
                    value = "Rawhide";
                } else {
                    re_search(contents, boost::regex("release (\\d[\\d.]*)"), &value);
                }
            }
        }

        // Debian uses the entire contents of the release file as the version
        if (value.empty() && name == os::debian) {
            value = lth_file::read(release_file::debian);
            boost::trim_right(value);
        }

        // Alpine uses the entire contents of the release file as the version
        if (value.empty() && name == os::alpine) {
            value = lth_file::read(release_file::alpine);
            boost::trim_right(value);
        }

        // Check for SuSE related distros, read the release file
        if (value.empty() && (
                name == os::suse ||
                name == os::suse_enterprise_server ||
                name == os::suse_enterprise_desktop ||
                name == os::open_suse)) {
            string contents = lth_file::read(release_file::suse);
            string major;
            string minor;
            if (re_search(contents, boost::regex("(?m)^VERSION\\s*=\\s*(\\d+)\\.?(\\d+)?"), &major, &minor)) {
                // Check that we have a minor version; if not, use the patch level
                if (minor.empty()) {
                    if (!re_search(contents, boost::regex("(?m)^PATCHLEVEL\\s*=\\s*(\\d+)"), &minor)) {
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
            boost::regex pattern;
            if (name == os::ubuntu) {
                file = release_file::lsb;
                pattern = "(?m)^DISTRIB_RELEASE=(\\d+\\.\\d+)(?:\\.\\d+)*";
            } else if (name == os::slackware) {
                file = release_file::slackware;
                pattern = "Slackware ([0-9.]+)";
            } else if (name == os::mageia) {
                file = release_file::mageia;
                pattern = "Mageia release ([0-9.]+)";
            } else if (name == os::linux_mint) {
                file = release_file::linux_mint_info;
                pattern = "(?m)^RELEASE=(\\d+)";
            } else if (name == os::openwrt) {
                file = release_file::openwrt_version;
                pattern = "(?m)^(\\d+\\.\\d+.*)";
            } else if (name == os::arista_eos) {
                file = release_file::arista_eos;
                pattern = "Arista Networks EOS (\\d+\\.\\d+\\.\\d+[A-M]?)";
            }
            if (file) {
                string contents = lth_file::read(file);
                re_search(contents, pattern, &value);
            }
        }

        // For VMware ESX, execute the vmware tool
        if (value.empty() && name == os::vmware_esx) {
            bool success;
            string output, none;
            tie(success, output, none) = execute("vmware", { "-v" });
            if (success) {
                re_search(output, boost::regex("VMware ESX .*?(\\d.*)"), &value);
            }
        }

        // For Amazon, use the distro release
        if (value.empty() && name == os::amazon) {
            return distro_release;
        }

        return value;
    }

    tuple<string, string> os_linux::parse_release(string const& name, string const& release) const
    {
        return facter::facts::resolvers::operating_system_resolver::parse_distro(name, release);
    }

}}}  // namespace facter::facts::linux
