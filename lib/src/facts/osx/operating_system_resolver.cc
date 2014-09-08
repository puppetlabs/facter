#include <facter/facts/osx/operating_system_resolver.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace osx {

    string operating_system_resolver::determine_operating_system_major_release(collection& facts, string const& operating_system, string const& os_release)
    {
        string value;
        auto pos = os_release.find('.');
        if (pos != string::npos) {
            value = os_release.substr(0, pos);
        }
        return value;
    }

    string operating_system_resolver::determine_operating_system_minor_release(collection& facts, string const& operating_system, string const& os_release)
    {
        string value;
        re_search(os_release, "\\d+\\.(\\d+)", &value);
        return value;
    }

}}}  // namespace facter::facts::osx
