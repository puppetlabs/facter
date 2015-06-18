#include <internal/facts/solaris/operating_system_resolver.hpp>
#include <internal/util/regex.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/os_family.hpp>
#include <leatherman/file_util/file.hpp>

using namespace std;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace solaris {

    static string get_family(string const& name)
    {
        if (!name.empty()) {
            static map<string, string> const systems = {
                { string(os::sunos),                    string(os_family::solaris) },
                { string(os::solaris),                  string(os_family::solaris) },
                { string(os::nexenta),                  string(os_family::solaris) },
                { string(os::omni),                     string(os_family::solaris) },
                { string(os::open_indiana),             string(os_family::solaris) },
                { string(os::smart),                    string(os_family::solaris) },
            };
            auto const& it = systems.find(name);
            if (it != systems.end()) {
                return it->second;
            }
        }
        return {};
    }

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        auto result = posix::operating_system_resolver::collect_data(facts);
        if (result.name == os::sunos) {
            result.name = os::solaris;
        }

        auto family = get_family(result.name);
        if (!family.empty()) {
            result.family = move(family);
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

        static boost::regex regexp_s10("Solaris \\d+ \\d+/\\d+ s(\\d+)x_u(\\d+)wos_");
        static boost::regex regexp_s11("Solaris (\\d+)[.](\\d+)");
        static boost::regex regexp_s11b("Solaris (\\d+) ");
        lth_file::each_line("/etc/release", [&](string& line) {
            string major, minor;
            if (re_search(line, regexp_s10, &major, &minor)) {
                result.release = major + "_u" + minor;
                result.major = move(major);
                result.minor = move(minor);
                return false;
            } else if (re_search(line, regexp_s11, &major, &minor)) {
                result.release = major + "." + minor;
                result.major = move(major);
                result.minor = move(minor);
                return false;
            } else if (re_search(line, regexp_s11b, &major)) {
                result.release = major + ".0";
                result.major = move(major);
                result.minor = "0";
                return false;
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::solaris
