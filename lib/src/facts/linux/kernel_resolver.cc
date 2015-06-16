#include <internal/facts/linux/kernel_resolver.hpp>
#include <internal/util/regex.hpp>
#include <boost/regex.hpp>
#include <tuple>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace linux {

    tuple<string, string> kernel_resolver::parse_version(string const& version) const
    {
        string major, minor;
        if (re_search(version, boost::regex("(\\d+\\.\\d+)(.*)"), &major, &minor)) {
            return make_tuple(major, minor);
        }
        return make_tuple(move(version), string());
    }

}}}  // namespace facter::facts::resolvers
