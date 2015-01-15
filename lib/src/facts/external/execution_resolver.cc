#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::execution;
using namespace facter::facts;
using namespace facter::facts::external;

namespace facter { namespace facts { namespace external {

    bool execution_resolver::can_resolve(string const& path) const
    {
        // If the path can be resolved as an executable, this resolver can handle it.
        // However, only allow absolute paths.
        LOG_DEBUG("checking execution on %1%", path);
        return !execution::which(path, {}).empty();
    }

    void execution_resolver::resolve(string const& path, collection& facts) const
    {
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
                string fact = line.substr(0, pos);
                boost::to_lower(fact);
                facts.add(move(fact), make_value<string_value>(line.substr(pos+1)));
                return true;
            }, { execution_options::defaults, execution_options::throw_on_failure });
        }
        catch (execution_exception& ex) {
            throw external_fact_exception(ex.what());
        }

        LOG_DEBUG("completed resolving facts from executable file \"%1%\".", path);
    }

}}}  // namespace facter::facts::external
