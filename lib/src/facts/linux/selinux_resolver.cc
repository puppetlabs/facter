#include <facter/facts/linux/selinux_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/file.hpp>
#include <facter/util/regex.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace linux {

    selinux_resolver::selinux_resolver() :
        resolver(
            "selinux",
            {
                fact::selinux,
                fact::selinux_enforced,
                fact::selinux_policyversion,
                fact::selinux_current_mode,
                fact::selinux_config_mode,
                fact::selinux_config_policy,
            })
    {
    }

    void selinux_resolver::resolve(collection& facts)
    {
        resolve_selinux_fs_facts(facts);
        resolve_selinux_config_facts(facts);
    }

    void selinux_resolver::resolve_selinux_fs_facts(collection& facts)
    {
        string selinux_mount;
        if (get_selinux_mountpoint(selinux_mount)) {
            facts.add(fact::selinux, make_value<string_value>("true"));

            resolve_selinux_enforce(facts, selinux_mount);
            resolve_selinux_policyvers(facts, selinux_mount);
        } else {
            facts.add(fact::selinux, make_value<string_value>("false"));
        }
    }

    void selinux_resolver::resolve_selinux_enforce(collection& facts, string const& mount)
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

    void selinux_resolver::resolve_selinux_policyvers(collection& facts, string const& mount)
    {
        string path = mount + "/policyvers";
        string buffer = file::read(path);

        if (buffer.empty()) {
            return;
        }

        facts.add(fact::selinux_policyversion, make_value<string_value>(move(buffer)));
    }

    void selinux_resolver::resolve_selinux_config_facts(collection& facts)
    {
        string buffer = file::read("/etc/selinux/config");

        if (buffer.empty()) {
            return;
        }

        string mode;
        if (re_search(buffer, "(?m)^SELINUX=(\\w+)$", &mode)) {
            facts.add(fact::selinux_config_mode, make_value<string_value>(move(mode)));
        }

        string type;
        if (re_search(buffer, "(?m)^SELINUXTYPE=(\\w+)$", &type)) {
            facts.add(fact::selinux_config_policy, make_value<string_value>(move(type)));
        }
    }

    bool selinux_resolver::get_selinux_mountpoint(string& selinux_mount)
    {
        re_adapter regexp("\\S+ (\\S+) selinuxfs");
        bool is_mounted = false;
        file::each_line("/proc/self/mounts", [&](string& line) {
            string mountpoint;
            if (re_search(line, regexp, &mountpoint)) {
                selinux_mount = mountpoint;
                is_mounted = true;
                return false;
            }
            return true;
        });
        return is_mounted;
    }

}}}  // facter::facts::linux

