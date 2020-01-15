#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>

#include <internal/facts/freebsd/operating_system_resolver.hpp>

using namespace std;
using namespace leatherman::execution;
using namespace leatherman::util;

namespace facter { namespace facts { namespace freebsd {

    void operating_system_resolver::collect_release_data(collection& facts, data& result)
    {
        auto exec = execute("freebsd-version");
        if (exec.success) {
            result.release = exec.output;

            string major, minor, branch;
            re_search(exec.output, boost::regex("(\\d+)\\.(\\d+)-(.*)"), &major, &minor, &branch);
            result.major = move(major);
            result.minor = move(minor);
            result.freebsd.branch = move(branch);

            string patchlevel;
            re_search(result.freebsd.branch, boost::regex("RELEASE-p(\\d+)"), &patchlevel);
            result.freebsd.patchlevel = move(patchlevel);
        }
    }
} } }  // namespace facter::facts::freebsd
