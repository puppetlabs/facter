#include <facter/facts/solaris/operating_system_resolver.hpp>
#include <facter/facts/os.hpp>
#include <facter/util/file.hpp>
#include <facter/util/regex.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace solaris {

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        auto result = posix::operating_system_resolver::collect_data(facts);
        if (result.name == os::sunos) {
            result.name = os::solaris;
        }

        /*
         Oracle Solaris 10 1/13 s10x_u11wos_24a X86
         Oracle Solaris 10 9/10 s10s_u9wos_14a SPARC
         Oracle Solaris 11 11/11 X86
         Oracle Solaris 11.2 X86

         There are a few places (operatingsystemmajrelease,...) where s10 and s11 differ
         for similar versioning. For e.g it shifts from `10_u11` to `11 11/11` these needs
         to be resolved further using the `pkg info kernel` command (TODO).
         */

        re_adapter regexp_s10("Solaris \\d+ \\d+/\\d+ s(\\d+)x_u(\\d+)wos_");
        re_adapter regexp_s11("Solaris (\\d+)[.](\\d+)");
        re_adapter regexp_s11b("Solaris (\\d+) ");
        file::each_line("/etc/release", [&](string& line) {
            string major;
            string minor;
            if (re_search(line, regexp_s10, &major, &minor)) {
                result.release = major + "_u" + minor;
                return false;
            } else if (re_search(line, regexp_s11, &major, &minor)) {
                result.release = major + "." + minor;
                return false;
            } else if (re_search(line, regexp_s11b, &major)) {
                result.release = major + ".0";
                return false;
            }
            return true;
        });
        return result;
    }

    tuple<string, string> operating_system_resolver::parse_release(string const& name, string const& release) const
    {
        string major, minor;
        re_search(release, "^(\\d+)(?:_u|\\.)(\\d+)", &major, &minor);
        return make_tuple(major, minor);
    }

}}}  // namespace facter::facts::solaris
