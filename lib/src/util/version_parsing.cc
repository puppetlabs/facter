#include <internal/util/version_parsing.hpp>
#include <internal/util/regex.hpp>
#include <boost/regex.hpp>

using namespace std;

namespace facter { namespace util {

    tuple<string, string> version_parsing::parse_kernel_version(string const& version)
    {
        auto pos = version.find('.');
        if (pos != string::npos) {
            auto second = version.find('.', pos + 1);
            if (second != string::npos) {
                pos = second;
            }
            return make_tuple(version.substr(0, pos), version.substr(pos + 1));
        }
        return make_tuple(move(version), string());
    }

    tuple<string, string> version_parsing::parse_linux_kernel_version(string const& version)
    {
        string major, minor;
        if (re_search(version, boost::regex("(\\d+\\.\\d+)(.*)"), &major, &minor)) {
            return make_tuple(major, minor);
        }
        return make_tuple(move(version), string());
    }

}}  // namespace facter::util
