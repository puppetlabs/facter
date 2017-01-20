#include <internal/facts/linux/operating_system_resolver.hpp>
#include <internal/facts/linux/release_file.hpp>
#include <internal/facts/linux/os_linux.hpp>
#include <internal/facts/linux/os_cisco.hpp>
#include <internal/facts/linux/os_coreos.hpp>
#include <internal/facts/linux/os_cumulus.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <map>
#include <vector>
#include <tuple>
#include <memory>

using namespace std;
using namespace leatherman::execution;
using namespace boost::filesystem;
using namespace leatherman::util;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

    static unique_ptr<os_linux> get_os()
    {
        auto release_info = os_linux::key_value_file(release_file::os, {"NAME", "CISCO_RELEASE_INFO", "ID"});
        auto const& name = release_info["NAME"];
        auto const& id = release_info["ID"];
        if (name == "Cumulus Linux") {
            return unique_ptr<os_linux>(new os_cumulus());
        } else if (name == "CoreOS" || id == "coreos") {
            return unique_ptr<os_linux>(new os_coreos());
        } else {
            auto const& cisco = release_info["CISCO_RELEASE_INFO"];
            boost::system::error_code ec;
            if (!cisco.empty() && is_regular_file(cisco, ec)) {
                return unique_ptr<os_linux>(new os_cisco(cisco));
            }
        }
        return unique_ptr<os_linux>(new os_linux());
    }

    static string get_selinux_mountpoint()
    {
        static boost::regex regexp("\\S+ (\\S+) selinuxfs");
        string mountpoint;
        lth_file::each_line("/proc/self/mounts", [&](string& line) {
            if (re_search(line, regexp, &mountpoint)) {
                return false;
            }
            return true;
        });
        return mountpoint;
    }

    operating_system_resolver::selinux_data operating_system_resolver::collect_selinux_data()
    {
        selinux_data result;
        result.supported = true;

        string mountpoint = get_selinux_mountpoint();
        result.enabled = !mountpoint.empty();
        if (!result.enabled) {
            return result;
        }

        // Get the policy version
        result.policy_version = lth_file::read(mountpoint + "/policyvers");

        // Check for enforcement
        string enforce = lth_file::read(mountpoint + "/enforce");
        if (!enforce.empty()) {
            if (enforce == "1") {
                result.enforced = true;
                result.current_mode = "enforcing";
            } else {
                result.current_mode = "permissive";
            }
        }

        // Parse the SELinux config for mode and policy
        static boost::regex mode_regex("(?m)^SELINUX=(\\w+)$");
        static boost::regex policy_regex("(?m)^SELINUXTYPE=(\\w+)$");
        lth_file::each_line("/etc/selinux/config", [&](string& line) {
            if (re_search(line, mode_regex, &result.config_mode)) {
                return true;
            }
            if (re_search(line, policy_regex, &result.config_policy)) {
                return true;
            }
            return true;
        });
        return result;
    }

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = posix::operating_system_resolver::collect_data(facts);

        // Populate distro info
        each_line("lsb_release", {"-a"}, [&](string& line) {
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

        auto implementation = get_os();
        auto name = implementation->get_name(result.distro.id);
        if (!name.empty()) {
            result.name = move(name);
        }

        auto family = implementation->get_family(result.name);
        if (!family.empty()) {
            result.family = move(family);
        }

        auto release = implementation->get_release(result.name, result.distro.release);
        if (!release.empty()) {
            result.release = move(release);
            tie(result.major, result.minor) = implementation->parse_release(result.name, result.release);
        }

        // Convert the architecture value depending on distro
        // For certain distros, use "amd64" for "x86_64"
        // For certain distros, use "x86" for "i386"
        if (result.architecture == "x86_64" && (
             result.name == os::debian ||
             result.name == os::gentoo ||
             result.name == os::kfreebsd ||
             result.name == os::ubuntu)) {
            result.architecture = "amd64";
        } else if (re_search(result.architecture, boost::regex("i[3456]86|pentium"))) {
            // For 32-bit, use "x86" for Gentoo and "i386" for everyone else
            if (result.name == os::gentoo) {
                result.architecture = "x86";
            } else {
                result.architecture = "i386";
            }
        }

        result.selinux = collect_selinux_data();

        return result;
    }

}}}  // namespace facter::facts::linux
