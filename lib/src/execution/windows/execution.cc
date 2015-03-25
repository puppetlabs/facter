#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/scope_exit.hpp>
#include <facter/util/scoped_resource.hpp>
#include <internal/execution/execution.hpp>
#include <internal/util/scoped_env.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
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

    void log_execution(string const& file, vector<string> const* arguments);

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
    static tuple<scoped_resource<HANDLE>, scoped_resource<HANDLE>> CreatePipeThrow(DWORD read_mode = 0, DWORD write_mode = 0)
    {
        static LONG counter = 0;

        // The only supported flag is FILE_FLAG_OVERLAPPED
        if ((read_mode | write_mode) & (~FILE_FLAG_OVERLAPPED)) {
            throw execution_exception("cannot create output pipe: invalid flag specified.");
        }

        SECURITY_ATTRIBUTES attributes = {};
        attributes.nLength = sizeof(SECURITY_ATTRIBUTES);
        attributes.bInheritHandle = TRUE;
        attributes.lpSecurityDescriptor = NULL;

        // Format a name for the pipe based on the process and counter
        wstring name = boost::nowide::widen((boost::format("\\\\.\\Pipe\\facter.%1%.%2%") %
            GetCurrentProcessId() %
            InterlockedIncrement(&counter)).str());

        // Create the read pipe
        scoped_resource<HANDLE> read_handle(CreateNamedPipeW(
            name.c_str(),
            PIPE_ACCESS_INBOUND | read_mode,
            PIPE_TYPE_BYTE | PIPE_WAIT,
            1,
            4096,
            4096,
            0,
            &attributes), CloseHandle);

        if (read_handle == INVALID_HANDLE_VALUE) {
            LOG_ERROR("failed to create read pipe: %1%.", system_error());
            throw execution_exception("failed to create read pipe.");
        }

        // Open the write pipe
        scoped_resource<HANDLE> write_handle(CreateFileW(
            name.c_str(),
            GENERIC_WRITE,
            0,
            &attributes,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL | write_mode,
            nullptr), CloseHandle);

        if (write_handle == INVALID_HANDLE_VALUE) {
            LOG_ERROR("failed to create write pipe: %1%.", system_error());
            throw execution_exception("failed to create write pipe.");
        }
        return make_tuple(move(read_handle), move(write_handle));
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

    // Represents information about a pipe
    struct pipe
    {
        pipe(string pipe_name, HANDLE pipe_handle, function<bool(string const&)> const& cb) :
            name(std::move(pipe_name)),
            handle(pipe_handle),
            overlapped{},
            pending(false),
            callback(cb)
        {
            if (handle != INVALID_HANDLE_VALUE) {
                event = scoped_resource<HANDLE>(CreateEvent(nullptr, TRUE, FALSE, nullptr), CloseHandle);
                if (!event) {
                    LOG_ERROR("failed to create %1% read event: %2%.", name, system_error());
                    throw execution_exception("failed to create read event.");
                }
                overlapped.hEvent = event;
            }
        }

        const string name;
        HANDLE handle;
        OVERLAPPED overlapped;
        scoped_resource<HANDLE> event;
        bool pending;
        string buffer;
        function<bool(string const&)> const& callback;
    };

    static void read_from_child(DWORD child, array<pipe, 2>& pipes, uint32_t timeout, HANDLE timer)
    {
        vector<HANDLE> wait_handles;
        while (true)
        {
            // Read from all pipes
            for (auto& pipe : pipes) {
                // If the handle is closed or is pending, skip
                if (pipe.handle == INVALID_HANDLE_VALUE || pipe.pending) {
                    break;
                }

                // Read the pipe until pending
                while (true) {
                    // Before doing anything, check to see if there's been a timeout
                    // This is done pre-emptively in case ReadFile never returns ERROR_IO_PENDING
                    if (timeout && WaitForSingleObject(timer, 0) == WAIT_OBJECT_0) {
                        throw timeout_exception((boost::format("command timed out after %1% seconds.") % timeout).str(), static_cast<size_t>(child));
                    }

                    // Read the data
                    pipe.buffer.resize(4096);
                    DWORD count = 0;
                    if (!ReadFile(pipe.handle, &pipe.buffer[0], pipe.buffer.size(), &count, &pipe.overlapped)) {
                        // Treat broken pipes as closed pipes
                        if (GetLastError() == ERROR_BROKEN_PIPE) {
                            pipe.handle = INVALID_HANDLE_VALUE;
                            break;
                        }
                        // Check to see if it's a pending operation
                        if (GetLastError() == ERROR_IO_PENDING) {
                            pipe.pending = true;
                            break;
                        }
                        LOG_ERROR("failed to read child %1% output: %2%.", pipe.name, system_error());
                        throw execution_exception("failed to read child process output.");
                    }

                    // Check for closed pipe
                    if (count == 0) {
                        pipe.handle = INVALID_HANDLE_VALUE;
                        break;
                    }

                    // Read completed immediately, process the data
                    pipe.buffer.resize(count);
                    if (!pipe.callback(pipe.buffer)) {
                        // Callback signaled that we're done
                        return;
                    }
                }
            }

            // All pipes should be pending now
            wait_handles.clear();
            for (auto const& pipe : pipes) {
                if (pipe.handle == INVALID_HANDLE_VALUE || !pipe.pending) {
                    continue;
                }
                wait_handles.push_back(pipe.event);
            }

            // If no wait handles, then we're done processing
            if (wait_handles.empty()) {
                return;
            }

            if (timeout) {
                wait_handles.push_back(timer);
            }

            // Wait for data (and, optionally, timeout)
            auto result = WaitForMultipleObjects(wait_handles.size(), wait_handles.data(), FALSE, INFINITE);
            if (result >= (WAIT_OBJECT_0 + wait_handles.size())) {
                LOG_ERROR("failed to wait for child process output: %1%.", system_error());
                throw execution_exception("failed to wait for child process output.");
            }

            // Check for timeout
            DWORD index = result - WAIT_OBJECT_0;
            if (timeout && wait_handles[index] == timer) {
                throw timeout_exception((boost::format("command timed out after %1% seconds.") % timeout).str(), static_cast<size_t>(child));
            }

            // Find the pipe for the event that was signalled
            for (auto& pipe : pipes) {
                if (pipe.handle == INVALID_HANDLE_VALUE || !pipe.pending || pipe.event != wait_handles[index]) {
                    continue;
                }

                // Pipe is no longer pending
                pipe.pending = false;

                // Get the overlapped result and process it
                DWORD count = 0;
                if (!GetOverlappedResult(pipe.handle, &pipe.overlapped, &count, FALSE)) {
                    if (GetLastError() != ERROR_BROKEN_PIPE) {
                        LOG_ERROR("failed to get asynchronous %1% read result: %2%.", pipe.name, system_error());
                        throw execution_exception("failed to get asynchronous read result.");
                    }
                    // Treat a broken pipe as nothing left to read
                    count = 0;
                }
                // Check for closed pipe
                if (count == 0) {
                    pipe.handle = INVALID_HANDLE_VALUE;
                    break;
                }

                // Read completed, process the data
                pipe.buffer.resize(count);
                if (!pipe.callback(pipe.buffer)) {
                    // Callback signaled that we're done
                    return;
                }
                break;
            }
        }
    }

    tuple<bool, string, string> execute(
        string const& file,
        vector<string> const* arguments,
        map<string, string> const* environment,
        function<bool(string&)> const& stdout_callback,
        function<bool(string&)> const& stderr_callback,
        option_set<execution_options> const& options,
        uint32_t timeout)
    {
        // Search for the executable
        string executable = which(file);
        log_execution(executable.empty() ? file : executable, arguments);
        if (executable.empty()) {
            LOG_DEBUG("%1% was not found on the PATH.", file);
            if (options[execution_options::throw_on_nonzero_exit]) {
                throw child_exit_exception("child process returned non-zero exit status.", 127, {}, {});
            }
            return make_tuple(false, "", "");
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
        scoped_resource<HANDLE> stdInRd, stdInWr;
        tie(stdInRd, stdInWr) = CreatePipeThrow();
        if (!SetHandleInformation(stdInWr, HANDLE_FLAG_INHERIT, 0)) {
            throw execution_exception("pipe could not be modified");
        }

        scoped_resource<HANDLE> stdOutRd, stdOutWr;
        tie(stdOutRd, stdOutWr) = CreatePipeThrow(FILE_FLAG_OVERLAPPED, 0);
        if (!SetHandleInformation(stdOutRd, HANDLE_FLAG_INHERIT, 0)) {
            throw execution_exception("pipe could not be modified");
        }

        scoped_resource<HANDLE> stdErrRd(INVALID_HANDLE_VALUE, nullptr), stdErrWr(INVALID_HANDLE_VALUE, nullptr);
        if (!options[execution_options::redirect_stderr_to_stdout]) {
            // If redirecting to null, open the "NUL" device and inherit the handle
            if (options[execution_options::redirect_stderr_to_null]) {
                SECURITY_ATTRIBUTES attributes = {};
                attributes.nLength = sizeof(SECURITY_ATTRIBUTES);
                attributes.bInheritHandle = TRUE;
                stdErrWr = scoped_resource<HANDLE>(CreateFileW(L"nul", GENERIC_WRITE, FILE_SHARE_WRITE, &attributes, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr), CloseHandle);
                if (stdErrWr == INVALID_HANDLE_VALUE) {
                    throw execution_exception("cannot open NUL device for redirecting stderr.");
                }
            } else {
                // Otherwise, we're reading from stderr, so create a pipe
                tie(stdErrRd, stdErrWr) = CreatePipeThrow(FILE_FLAG_OVERLAPPED, 0);
                if (!SetHandleInformation(stdErrRd, HANDLE_FLAG_INHERIT, 0)) {
                    throw execution_exception("pipe could not be modified");
                }
            }
        }

        // Execute the command with arguments. Prefix arguments with the executable, or quoted arguments won't work.
        auto commandLine = arguments ?
            boost::nowide::widen(ArgvToCommandLine({ executable }) + " " + ArgvToCommandLine(*arguments)) : L"";

        STARTUPINFO startupInfo = {};
        startupInfo.cb = sizeof(startupInfo);
        startupInfo.dwFlags |= STARTF_USESTDHANDLES;
        startupInfo.hStdInput = stdInRd;
        startupInfo.hStdOutput = stdOutWr;

        // Set up stderr redirection to out or the pipe (which may be INVALID_HANDLE_VALUE, i.e. "null")
        if (options[execution_options::redirect_stderr_to_stdout]) {
            startupInfo.hStdError = stdOutWr;
        } else {
            startupInfo.hStdError = stdErrWr;
        }

        PROCESS_INFORMATION procInfo = {};

        if (!CreateProcessW(
            boost::nowide::widen(executable).c_str(),
            &commandLine[0], /* Pass a modifiable string buffer; the contents may be modified */
            NULL,           /* Don't allow child process to inherit process handle */
            NULL,           /* Don't allow child process to inherit thread handle */
            TRUE,           /* Inherit handles from the calling process for communication */
            CREATE_NO_WINDOW,
            options[execution_options::merge_environment] ? NULL : modified_environ.data(),
            NULL,           /* Use existing current directory */
            &startupInfo,   /* STARTUPINFO for child process */
            &procInfo)) {   /* PROCESS_INFORMATION pointer for output */
            LOG_ERROR("failed to create process: %1%.", system_error());
            throw execution_exception("failed to create child process.");
        }

        // Release unused pipes, to avoid any races in process completion.
        stdInWr.release();
        stdInRd.release();
        stdOutWr.release();
        stdErrWr.release();

        scoped_resource<HANDLE> hProcess(move(procInfo.hProcess), CloseHandle);
        scoped_resource<HANDLE> hThread(move(procInfo.hThread), CloseHandle);

        // Use a Job Object to group any child processes spawned by the CreateProcess invocation, so we can
        // easily stop them in case of a timeout.
        scoped_resource<HANDLE> hJob(CreateJobObjectW(nullptr, nullptr), CloseHandle);
        if (hJob == NULL) {
            LOG_ERROR("failed to create job object: %1%.", system_error());
            throw execution_exception("failed to create job object.");
        } else if (!AssignProcessToJobObject(hJob, hProcess)) {
            LOG_ERROR("failed to associate process with job object: %1%.", system_error());
            throw execution_exception("failed to associate process with job object.");
        }

        bool terminate = true;
        scope_exit reaper([&]() {
            if (terminate) {
                // Terminate the process on an exception
                if (!TerminateJobObject(hJob, -1)) {
                    LOG_ERROR("failed to terminate process: %1%.", system_error());
                }
            }
        });

        // Create a waitable timer if given a timeout
        scoped_resource<HANDLE> timer;
        if (timeout) {
            timer = scoped_resource<HANDLE>(CreateWaitableTimer(nullptr, TRUE, nullptr), CloseHandle);
            if (!timer) {
                LOG_ERROR("failed to create waitable timer: %1%.", system_error());
                throw execution_exception("failed to create waitable timer.");
            }

            // "timeout" in X intervals in the future (1 interval = 100 ns)
            // The negative value indicates relative to the current time
            LARGE_INTEGER future;
            future.QuadPart = timeout * -10000000ll;
            if (!SetWaitableTimer(timer, &future, 0, nullptr, nullptr, FALSE)) {
                LOG_ERROR("failed to set waitable timer: %1%.", system_error());
                throw execution_exception("failed to set waitable timer.");
            }
        }

        string output, error;
        tie(output, error) = process_streams(options[execution_options::trim_output], stdout_callback, stderr_callback, [&](function<bool(string const&)> const& process_stdout, function<bool(string const&)> const& process_stderr) {
            // Read the child output
            array<pipe, 2> pipes = { {
                pipe("stdout", stdOutRd, process_stdout),
                pipe("stderr", stdErrRd, process_stderr)
            } };

            read_from_child(procInfo.dwProcessId, pipes, timeout, timer);
        });

        stdOutRd.release();
        stdErrRd.release();

        HANDLE handles[2] = { hProcess, timer };
        auto wait_result = WaitForMultipleObjects(timeout ? 2 : 1, handles, FALSE, INFINITE);
        if (wait_result == WAIT_OBJECT_0) {
            // Process has terminated
            terminate = false;
        } else if (wait_result == WAIT_OBJECT_0 + 1) {
            // Timeout while waiting on the process to complete
            throw timeout_exception((boost::format("command timed out after %1% seconds.") % timeout).str(), static_cast<size_t>(procInfo.dwProcessId));
        } else {
            LOG_ERROR("failed to wait for child process to terminate: %1%.", system_error());
            throw execution_exception("failed to wait for child process to terminate.");
        }

        // Now check the process return status.
        DWORD exit_code;
        if (!GetExitCodeProcess(hProcess, &exit_code)) {
            throw execution_exception("error retrieving exit code of completed process");
        }

        LOG_DEBUG("process exited with exit code %1%.", exit_code);

        if (exit_code != 0 && options[execution_options::throw_on_nonzero_exit]) {
            throw child_exit_exception("child process returned non-zero exit status.", exit_code, output, error);
        }
        return make_tuple(exit_code == 0, move(output), move(error));
    }

}}  // namespace facter::executions
