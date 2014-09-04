#include <facter/facts/solaris/operating_system_resolver.hpp>
#include <facter/facts/posix/os.hpp>
#include <facter/facts/posix/os_family.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/util/file.hpp>
#include <facter/util/regex.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::facts::posix;
namespace facter { namespace facts { namespace solaris {

    void operating_system_resolver::resolve_operating_system(collection& facts)
    {
        auto kernel = facts.get<string_value>(fact::kernel);
        string value;
        if (kernel && kernel->value() == os::sunos) {
            value = os_family::solaris;
        }

        // If no value, default to the base implementation
        if (value.empty()) {
            posix::operating_system_resolver::resolve_operating_system(facts);
            return;
        }
        // Add the fact
        facts.add(fact::operating_system, make_value<string_value>(move(value)));
    }

    void operating_system_resolver::resolve_operating_system_release(collection& facts)
    {
        /*
         Oracle Solaris 10 1/13 s10x_u11wos_24a X86
         Oracle Solaris 10 9/10 s10s_u9wos_14a SPARC
         Oracle Solaris 11 11/11 X86
         Oracle Solaris 11.2 X86

         There are a few places (operatingsystemmajrelease,...) where s10 and s11 differ
         for similar versioning. For e.g it shifts from `10_u11` to `11 11/11` these needs
         to be resolved further using the `pkg info kernel` command (TODO).
         */

        string value;
        re_adapter regexp_s10("Solaris \\d+ \\d+/\\d+ s(\\d+)x_u(\\d+)wos_");
        re_adapter regexp_s11("Solaris (\\d+)[.](\\d+)");
        re_adapter regexp_s11b("Solaris (\\d+) ");
        file::each_line("/etc/release", [&](string& line) {
            string major;
            string minor;
            if (re_search(line, regexp_s10, &major, &minor)) {
                value = major + "_u" + minor;
            } else if (re_search(line, regexp_s11, &major, &minor)) {
                value = major + "_u" + minor;
            } else if (re_search(line, regexp_s11b, &major)) {
                value = major + "_u0";
            }
            return value.empty();
        });

        // Use the base implementation if we have no value
        if (value.empty()) {
            posix::operating_system_resolver::resolve_operating_system_release(facts);
            return;
        }
        facts.add(fact::operating_system_release, make_value<string_value>(move(value)));
    }

    void operating_system_resolver::resolve_operating_system_major_release(collection& facts) {
        auto kernel = facts.get<string_value>(fact::operating_system_release, false)->value();
        auto pos = kernel.find('_');
        if (pos != string::npos) {
            kernel = kernel.substr(0, pos);
        }
        facts.add(fact::operating_system_major_release, make_value<string_value>(move(kernel)));
    }

}}}  // namespace facter::facts::solaris
