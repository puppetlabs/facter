#include <internal/facts/posix/xen_resolver.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;
using namespace boost::filesystem;
namespace bs = boost::system;

namespace facter { namespace facts { namespace posix {

    string xen_resolver::xen_command()
    {
        constexpr char const* xen_toolstack = "/usr/lib/xen-common/bin/xen-toolstack";

        bs::error_code ec;
        if (exists(xen_toolstack, ec) && !ec) {
            auto exec = execute(xen_toolstack);
            if (exec.success) {
                return exec.output;
            } else {
                LOG_DEBUG("failure executing %1%: %2%", xen_toolstack, exec.error);
                return {};
            }
        } else {
            LOG_TRACE("xen toolstack command not found: %1%", ec.message());

            static vector<string> xen_commands{"/usr/sbin/xl", "/usr/sbin/xm"};
            for (auto const& cmd : xen_commands) {
                auto cmd_path = which(cmd);
                if (!cmd_path.empty()) {
                    return cmd_path;
                }
            }

            LOG_TRACE("no xen commands found");
            return {};
        }
    }

}}}  // namespace facter::facts::posix
