#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <facter/execution/execution.hpp>
#include <unistd.h>

using namespace std;
using namespace facter::execution;
using namespace facter::facts;
using namespace facter::facts::external;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.external.execution.posix");

namespace facter { namespace facts { namespace external {

    bool execution_resolver::resolve(string const& path, collection& facts) const
    {
        if (access(path.c_str(), X_OK) == -1) {
            // Because this is the last resolver to execute, log a warning if it's not executable
            LOG_WARNING("file \"%1%\" is not executable.", path);
            return false;
        }

        LOG_DEBUG("resolving facts from executable file \"%1%\".", path);

        try
        {
            execution::each_line(path, [&facts](string const& line) {
                auto pos = line.find('=');
                if (pos == string::npos) {
                    LOG_DEBUG("ignoring line in output: %1%", line);
                    return true;
                }
                // Add as a string fact
                facts.add(to_lower(line.substr(0, pos)), make_value<string_value>(line.substr(pos+1)));
                return true;
            }, { execution_options::defaults, execution_options::throw_on_failure });
        }
        catch (execution_exception& ex) {
            throw external_fact_exception(ex.what());
        }

        LOG_DEBUG("completed resolving facts from executable file \"%1%\".", path);
        return true;
    }

}}}  // namespace facter::facts::external
