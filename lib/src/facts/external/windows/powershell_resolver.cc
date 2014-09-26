#include <facter/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::execution;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("facts.external.powershell");

namespace facter { namespace facts { namespace external {

    bool powershell_resolver::can_resolve(string const& file) const
    {
        try {
            path p = file;
            return boost::iends_with(file, ".ps1") && is_regular_file(p);
        } catch (filesystem_error &e) {
            LOG_TRACE("error reading status of path %1%: %2%", file, e.what());
            return false;
        }
    }

    void powershell_resolver::resolve(string const& file, collection& facts) const
    {
        LOG_DEBUG("resolving facts from powershell script \"%1%\".", file);

        try
        {
            execution::each_line("powershell", {"-NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File ", "\"" + file + "\""},
            [&facts](string const& line) {
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

        LOG_DEBUG("completed resolving facts from powershell script \"%1%\".", file);
    }

}}}  // namespace facter::facts::external
