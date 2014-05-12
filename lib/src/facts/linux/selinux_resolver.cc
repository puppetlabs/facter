#include <facter/facts/fact_map.hpp>
#include <facter/facts/linux/selinux_resolver.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/util/file.hpp>
#include <re2/re2.h>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace linux {

    void selinux_resolver::resolve_facts(fact_map& facts)
    {
        resolve_selinux_fs_facts(facts);
        resolve_selinux_config_facts(facts);
    }

    void selinux_resolver::resolve_selinux_fs_facts(fact_map& facts)
    {
        string selinux_mount;
        if (selinux_fs_mountpoint(selinux_mount)) {
            facts.add(fact::selinux, make_value<string_value>("true"));

            resolve_selinux_enforce(facts, selinux_mount);
            resolve_selinux_policyvers(facts, selinux_mount);
        } else {
            facts.add(fact::selinux, make_value<string_value>("false"));
        }
    }

    void selinux_resolver::resolve_selinux_enforce(fact_map& facts, string const& mount)
    {
        string path = mount + "/enforce";
        string buffer = file::read(path);

        if (buffer.empty()) {
            return;
        }

        if (buffer == "1") {
            facts.add(fact::selinux_enforced, make_value<string_value>("true"));
            facts.add(fact::selinux_current_mode, make_value<string_value>("enforcing"));
        } else {
            facts.add(fact::selinux_enforced, make_value<string_value>("false"));
            facts.add(fact::selinux_current_mode, make_value<string_value>("permissive"));
        }
    }

    void selinux_resolver::resolve_selinux_policyvers(fact_map& facts, string const& mount)
    {
        string path = mount + "/policyvers";
        string buffer = file::read(path);

        if (buffer.empty()) {
            return;
        }

        facts.add(fact::selinux_policyversion, make_value<string_value>(move(buffer)));
    }

    /**
     * Called to resolve all facts read from the SELinux configuration file.
     * @param facts The fact map that is resolving facts.
     */
    void selinux_resolver::resolve_selinux_config_facts(fact_map& facts)
    {
        string buffer = file::read("/etc/selinux/config");

        if (buffer.empty()) {
            return;
        }

        string mode;
        if (RE2::PartialMatch(buffer, "(?m)^SELINUX=(\\w+)$" , &mode)) {
            facts.add(fact::selinux_config_mode, make_value<string_value>(move(mode)));
        }

        string type;
        if (RE2::PartialMatch(buffer, "(?m)^SELINUXTYPE=(\\w+)$" , &type)) {
            facts.add(fact::selinux_config_policy, make_value<string_value>(move(type)));
        }
    }

    /**
     * Determine if the selinux pseudo filesystem is mounted and where it's mounted.
     * @param selinux_mount The selinux mountpoint
     */
    bool selinux_resolver::selinux_fs_mountpoint(string& selinux_mount)
    {
        RE2 regexp("\\S+ (\\S+) selinuxfs");
        bool is_mounted = false;
        file::each_line("/proc/self/mounts", [&](string& line) {
            string mountpoint;
            if (RE2::PartialMatch(line, regexp, &mountpoint)) {
                selinux_mount = mountpoint;
                is_mounted = true;
                return false;
            }
            return true;
        });
        return is_mounted;
    }

}}}  // facter::facts::linux

