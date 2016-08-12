#include <internal/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace leatherman::execution;
using namespace leatherman::windows;
using namespace boost::filesystem;

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
            string pwrshell = "powershell";

            // When facter is a 32-bit process running on 64-bit windows (such as in a 32-bit puppet installation that
            // includes native facter), PATH-lookp finds the 32-bit powershell and leads to problems. For example, if
            // using powershell to read values from the registry, it will read the 32-bit view of the registry. Also 32
            // and 64-bit versions have different modules available (since PSModulePath is in system32). Use the
            // system32 fact to find the correct powershell executable.
            auto system32 = facts.get<string_value>(fact::windows_system32);
            if (system32) {
                auto pathNative = path(system32->value()) / "WindowsPowerShell" / "v1.0" / "powershell.exe";
                auto pwrshellNative = which(pathNative.string());
                if (!pwrshellNative.empty()) {
                    pwrshell = move(pwrshellNative);
                }
            }

            string error;
            each_line(
                pwrshell,
                {
                    "-NoProfile",
                    "-NonInteractive",
                    "-NoLogo",
                    "-ExecutionPolicy",
                    "Bypass",
                    "-File",
                    file
                },
                [&facts](string const& line) {
                    auto pos = line.find('=');
                    if (pos == string::npos) {
                        LOG_DEBUG("ignoring line in output: %1%", line);
                        return true;
                    }
                    // Add as a string fact
                    string fact = line.substr(0, pos);
                    boost::to_lower(fact);
                    facts.add_external(move(fact), make_value<string_value>(line.substr(pos+1)));
                    return true;
                },
                [&](string const& line) {
                    if (!error.empty()) {
                        error += "\n";
                    }
                    error += line;
                    return true;
                },
                0,
                {
                    execution_options::trim_output,
                    execution_options::merge_environment,
                    execution_options::throw_on_failure
                });

            // Log a warning if there is error output from the command
            if (!error.empty()) {
                LOG_WARNING("external fact file \"%1%\" had output on stderr: %2%", file, error);
            }
        }
        catch (execution_exception& ex) {
            throw external_fact_exception(ex.what());
        }

        LOG_DEBUG("completed resolving facts from powershell script \"%1%\".", file);
    }

}}}  // namespace facter::facts::external
