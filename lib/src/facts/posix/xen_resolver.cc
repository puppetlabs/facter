#include <internal/facts/posix/xen_resolver.hpp>
#include <facter/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;
using namespace boost::filesystem;
namespace bs = boost::system;

namespace facter { namespace facts { namespace posix {

    string xen_resolver::xen_command()
    {
        constexpr char const* xen_toolstack = "/usr/lib/xen-common/bin/xen-toolstack";

        bs::error_code ec;
        if (exists(xen_toolstack, ec) && !ec) {
            bool success;
            string output, error;
            tie(success, output, error) = execute(xen_toolstack);
            if (success) {
                return output;
            } else {
                LOG_DEBUG("failure executing %1%: %2%", xen_toolstack, error);
                return {};
            }
        } else {
            LOG_TRACE("xen toolstack command not found: %1%", ec.message());

            static vector<string> xen_commands{"/usr/sbin/xl", "/usr/sbin/xm"};
            for (auto const& cmd : xen_commands) {
                auto cmd_path = execution::which(cmd);
                if (!cmd_path.empty()) {
                    return cmd_path;
                }
            }

            LOG_TRACE("no xen commands found");
            return {};
        }
    }

}}}  // namespace facter::facts::posix
