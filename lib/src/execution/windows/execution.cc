#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/scoped_resource.hpp>
#include <facter/util/windows/system_error.hpp>
#include <facter/util/scoped_env.hpp>
#include <facter/util/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>

#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/nowide/convert.hpp>

#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;
using namespace leatherman::logging;
using namespace boost::filesystem;
using namespace boost::algorithm;

namespace facter { namespace execution {

    const char *const command_shell = "cmd.exe";
    const char *const command_args = "/c";

    struct extpath_helper
    {
        vector<string> const& ext_paths() const
        {
            return _extpaths;
        }

        bool contains(const string & ext) const
        {
            return binary_search(_extpaths.begin(), _extpaths.end(), to_lower_copy(ext));
        }

     private:
        // Use sorted, lower-case operations to ignore case and use binary search.
        vector<string> _extpaths = {".bat", ".cmd", ".com", ".exe"};;
    };

    static bool is_executable(path const& p, extpath_helper const* helper = nullptr)
    {
        // If there's an error accessing file status, we assume is_executable
        // is false and return. The reason for failure doesn't matter to us.
        boost::system::error_code ec;
        bool isfile = is_regular_file(p, ec);
        if (ec) {
            LOG_TRACE("error reading status of path %1%: %2% (%3%)", p, ec.message(), ec.value());
        }

        if (helper) {
            // Checking extensions aren't needed if we explicitly specified it.
            // If helper was passed, then we haven't and should check the ext.
            isfile &= helper->contains(p.extension().string());
        }
        return isfile;
    }

    string which(string const& file, vector<string> const& directories)
    {
        // On Windows, everything has execute permission; Ruby determined
        // executability based on extension {com, exe, bat, cmd}. We'll do the
        // same check here using extpath_helper.
        static extpath_helper helper;

        // If the file is already absolute, return it if it's executable.
        path p = file;
        if (p.is_absolute()) {
            return is_executable(p, &helper) ? p.string() : string();
        }

        // Otherwise, check for an executable file under the given search paths
        for (auto const& dir : directories) {
            path p = path(dir) / file;
            if (!p.has_extension()) {
                path pext = p;
                for (auto const&ext : helper.ext_paths()) {
                    pext.replace_extension(ext);
                    if (is_executable(pext)) {
                        return pext.string();
                    }
                }
            }
            if (is_executable(p, &helper)) {
                return p.string();
            }
        }
        return {};
    }

    // Create a pipe, throwing if there's an error. Returns {read, write} handles.
    static tuple<scoped_resource<HANDLE>, scoped_resource<HANDLE>> CreatePipeThrow()
    {
        SECURITY_ATTRIBUTES saAttr = {};
        saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
        saAttr.bInheritHandle = TRUE;
        saAttr.lpSecurityDescriptor = NULL;

        HANDLE tmpHandleRd = NULL, tmpHandleWr = NULL;
        if (!CreatePipe(&tmpHandleRd, &tmpHandleWr, &saAttr, 0)) {
            throw execution_exception("pipe could not be created");
        }
        return make_tuple(scoped_resource<HANDLE>(move(tmpHandleRd), CloseHandle),
            scoped_resource<HANDLE>(move(tmpHandleWr), CloseHandle));
    }

    // Source: http://blogs.msdn.com/b/twistylittlepassagesallalike/archive/2011/04/23/everyone-quotes-arguments-the-wrong-way.aspx
    static string ArgvToCommandLine(vector<string> const& arguments)
    {
        // Unless we're told otherwise, don't quote unless we actually need to do so - hopefully avoid problems if
        // programs won't parse quotes properly.
        string commandline;
        for (auto const& arg : arguments) {
            if (arg.empty()) {
                continue;
            } else if (arg.find_first_of(" \t\n\v\"") == arg.npos) {
                commandline += arg;
            } else {
                commandline += '"';
                for (auto it = arg.begin(); ; ++it) {
                    unsigned num_back_slashes = 0;
                    while (it != arg.end() && *it == '\\') {
                        ++it;
                        ++num_back_slashes;
                    }

                    if (it == arg.end()) {
                        // Escape all backslashes, but let the terminating double quotation mark we add below be
                        // interpreted as a metacharacter.
                        commandline.append(num_back_slashes * 2, '\\');
                        break;
                    } else if (*it == '"') {
                        // Escape all backslashes and the following double quotation mark.
                        commandline.append(num_back_slashes * 2 + 1, '\\');
                        commandline.push_back(*it);
                    } else {
                        // Backslashes aren't special here.
                        commandline.append(num_back_slashes, '\\');
                        commandline.push_back(*it);
                    }
                }
                commandline += '"';
            }
            commandline += ' ';
        }

        // Strip the trailing space.
        boost::trim_right(commandline);
        return commandline;
    }

    pair<bool, string> execute(
        string const& file,
        vector<string> const* arguments,
        map<string, string> const* environment,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        // Search for the executable
        string executable = which(file);
        log_execution(executable.empty() ? file : executable, arguments);
        if (executable.empty()) {
            LOG_DEBUG("%1% was not found on the PATH.", file);
            if (options[execution_options::throw_on_nonzero_exit]) {
                throw child_exit_exception(127, "", "child process returned non-zero exit status.");
            }
            return { false, "" };
        }

        // Setup the execution environment
        vector<char> modified_environ;
        vector<scoped_env> scoped_environ;
        if (options[execution_options::merge_environment]) {
            // Modify the existing environment, then restore it after. There's no way to modify environment variables
            // after the child has started. An alternative would be to use GetEnvironmentStrings and add/modify the block,
            // but searching for and modifying existing environment strings to update would be cumbersome in that form.
            // See http://msdn.microsoft.com/en-us/library/windows/desktop/ms682009(v=vs.85).aspx
            if (!environment || environment->count("LC_ALL") == 0) {
                scoped_environ.emplace_back("LC_ALL", "C");
            }
            if (!environment || environment->count("LANG") == 0) {
                scoped_environ.emplace_back("LANG", "C");
            }
            if (environment) {
                for (auto const& kv : *environment) {
                    // Use scoped_env to save the old state and restore it on return.
                    LOG_DEBUG("child environment %1%=%2%", kv.first, kv.second);
                    scoped_environ.emplace_back(kv.first, kv.second);
                }
            }
        } else {
            // We aren't inheriting the environment, so create an environment block instead of changing existing env.
            // Environment variables must be sorted alphabetically and case-insensitive,
            // so copy them all into the same map with case-insensitive key compare:
            //   http://msdn.microsoft.com/en-us/library/windows/desktop/ms682009(v=vs.85).aspx
            std::map<string, string, bool(*)(string const&, string const&)> sortedEnvironment(
                [](string const& a, string const& b) { return ilexicographical_compare(a, b); });
            if (environment) {
                sortedEnvironment.insert(environment->begin(), environment->end());
            }

            // Insert LANG and LC_ALL if they aren't already present. Emplace ensures this behavior.
            sortedEnvironment.emplace("LANG", "C");
            sortedEnvironment.emplace("LC_ALL", "C");

            // An environment block is a NULL-terminated list of NULL-terminated strings.
            for (auto const& variable : sortedEnvironment) {
                LOG_DEBUG("child environment %1%=%2%", variable.first, variable.second);
                string var = variable.first + "=" + variable.second;
                for (auto c : var) {
                    modified_environ.push_back(c);
                }
                modified_environ.push_back('\0');
            }
            modified_environ.push_back('\0');
        }

        // Execute the command, reading the results into a buffer until there's no more to read.
        // See http://msdn.microsoft.com/en-us/library/windows/desktop/ms682499(v=vs.85).aspx
        // for details on redirecting input/output.
        try {
            scoped_resource<HANDLE> stdInRd, stdInWr;
            tie(stdInRd, stdInWr) = CreatePipeThrow();
            if (!SetHandleInformation(stdInWr, HANDLE_FLAG_INHERIT, 0)) {
                throw execution_exception("pipe could not be modified");
            }

            scoped_resource<HANDLE> stdOutRd, stdOutWr;
            tie(stdOutRd, stdOutWr) = CreatePipeThrow();
            if (!SetHandleInformation(stdOutRd, HANDLE_FLAG_INHERIT, 0)) {
                throw execution_exception("pipe could not be modified");
            }

            scoped_resource<HANDLE> stdErrRd, stdErrWr;

            // Execute the command with arguments. Prefix arguments with the executable, or quoted arguments won't work.
            auto commandLine = arguments ?
                boost::nowide::widen(ArgvToCommandLine({executable}) + " " + ArgvToCommandLine(*arguments)) : L"";

            STARTUPINFO startupInfo = {};
            startupInfo.cb = sizeof(startupInfo);
            startupInfo.dwFlags |= STARTF_USESTDHANDLES;
            startupInfo.hStdInput = stdInRd;
            startupInfo.hStdOutput = stdOutWr;
            if (options[execution_options::redirect_stderr]) {
                startupInfo.hStdError = stdOutWr;
            } else {
                startupInfo.hStdError = INVALID_HANDLE_VALUE;
            }

            PROCESS_INFORMATION procInfo = {};

            bool success = CreateProcessW(
                    boost::nowide::widen(executable).c_str(),
                    &commandLine[0], /* Pass a modifiable string buffer; the contents may be modified */
                    NULL,           /* Don't allow child process to inherit process handle */
                    NULL,           /* Don't allow child process to inherit thread handle */
                    TRUE,           /* Inherit handles from the calling process for communication */
                    CREATE_NO_WINDOW,
                    options[execution_options::merge_environment] ? NULL : modified_environ.data(),
                    NULL,           /* Use existing current directory */
                    &startupInfo,   /* STARTUPINFO for child process */
                    &procInfo);     /* PROCESS_INFORMATION pointer for output */

            // Release unused pipes, to avoid any races in process completion.
            stdInWr.release();
            stdInRd.release();
            stdOutWr.release();
            stdErrWr.release();

            if (!success) {
                throw execution_exception("child process failed to start");
            }
            scoped_resource<HANDLE> hProcess(move(procInfo.hProcess), CloseHandle);
            scoped_resource<HANDLE> hThread(move(procInfo.hThread), CloseHandle);

            string result = process_stream([&](string &buffer) {
                DWORD count;
                buffer.resize(4096);
                auto readSucceeded = ReadFile(stdOutRd, &buffer[0], buffer.size(), &count, NULL);
                if (count != 0 && !readSucceeded) {
                    // Not an asynchronous read, so it won't return with pending IO.
                    assert(GetLastError() != ERROR_IO_PENDING);
                    throw execution_exception("failed to read child stdout");
                }
                buffer.resize(count);
                // Halt if nothing was read.
                return count != 0;
            }, callback, options);

            // Close the read pipe; this may be done before all data is read when the callback returns false
            // If the child hasn't sent all the data yet, this may signal SIGPIPE on next write
            stdOutRd.release();

            auto waitStatus = WaitForSingleObject(hProcess, INFINITE);
            if (waitStatus != WAIT_OBJECT_0) {
                // Not a mutex, and specified INFINITE timeout, so only WAIT_FAILED should be possible.
                assert(waitStatus == WAIT_FAILED);
                throw execution_exception("error waiting on execution");
            }

            // Now check the process return status.
            DWORD exitCode;
            if (!GetExitCodeProcess(hProcess, &exitCode)) {
                throw execution_exception("error retrieving exit code of completed process");
            }

            if (exitCode != 0) {
                // Process signaled finished, so it should not return STILL_ACTIVE.
                assert(exitCode != STILL_ACTIVE);
                throw child_exit_exception(exitCode, result, "child process returned non-zero exit status.");
            }
            return { true, move(result) };
        } catch (child_exit_exception &e) {
            if (options[execution_options::throw_on_nonzero_exit]) {
                throw;
            } else {
                LOG_DEBUG("%1% (%2%): %3%", e.what(), e.status_code(), system_error());
                return { false, move(e.output()) };
            }
        }
    }

}}  // namespace facter::executions
