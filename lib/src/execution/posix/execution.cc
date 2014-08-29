#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/posix/scoped_descriptor.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::posix;
using namespace facter::logging;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("execution");

// Declare environ for OSX
extern char** environ;

namespace facter { namespace execution {

    uint64_t get_max_descriptor_limit()
    {
#ifdef _SC_OPEN_MAX
        {
            auto open_max = sysconf(_SC_OPEN_MAX);
            if (open_max > 0) {
                return open_max;
            }
        }
#endif  // _SC_OPEN_MAX

#ifdef RLIMIT_NOFILE
        {
            rlimit lim;
            if (getrlimit(RLIMIT_NOFILE, &lim) == 0) {
                return lim.rlim_cur;
            }
        }
#endif  // RLIMIT_NOFILE

#ifdef OPEN_MAX
        return OPEN_MAX;
#else
        return 256;
#endif  // OPEN_MAX
    }

    string which(string const& file, vector<string> const& directories)
    {
        // If the file is already absolute, return it if it's executable
        path p = file;
        boost::system::error_code ec;
        if (p.is_absolute()) {
            return is_regular_file(p, ec) && access(p.c_str(), X_OK) == 0 ? p.string() : string();
        }

        // Otherwise, check for an executable file under the given search paths
        for (auto const& dir : directories) {
            path p = path(dir) / file;
            if (is_regular_file(p, ec) && access(p.c_str(), X_OK) == 0) {
                return p.string();
            }
        }
        return {};
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

        // Create the pipes for stdin/stdout/stderr redirection
        int pipes[2];
        if (pipe(pipes) < 0) {
            throw execution_exception("failed to allocate pipe for input redirection.");
        }
        scoped_descriptor stdin_read(pipes[0]);
        scoped_descriptor stdin_write(pipes[1]);

        if (pipe(pipes) < 0) {
            throw execution_exception("failed to allocate pipe for output redirection.");
        }
        scoped_descriptor stdout_read(pipes[0]);
        scoped_descriptor stdout_write(pipes[1]);

        // Fork the child process
        pid_t child = fork();
        if (child < 0) {
            throw execution_exception("failed to fork child process.");
        }

        // A non-zero child pid means we're running in the context of the parent process
        if (child)
        {
            // Get a special logger used specifically for child process output
            std::string logger = "|";

            // Close the unused descriptors
            stdin_read.release();
            stdout_write.release();
            stdin_write.release();

            ostringstream output;
            char buffer[4096];
            bool reading = true;
            while (reading)
            {
                // Read from the pipe
                auto count = read(stdout_read, buffer, sizeof(buffer));
                if (count == 0) {
                    reading = false;
                    continue;
                }
                if (count < 0) {
                    if (errno == EINTR) {
                        // The call to read was interrupted by a signal before any data was read. Retry read.
                        // See http://www.gnu.org/software/libc/manual/html_node/Interrupted-Primitives.html
                        // This happens in Xcode's debugging.
                        LOG_DEBUG("child pipe read was interrupted and will be retried: %1% (%2%).", strerror(errno), errno);
                        errno = 0;
                        continue;
                    }

                    throw execution_exception("failed to read child output.");
                }

                // If given no callback, buffer the entire output
                if (!callback) {
                    output.write(buffer, count);
                    continue;
                }

                // Otherwise, scan the output for lines
                streamsize size = 0;
                streamsize offset = 0;
                for (decltype(count) i = 0; reading && i < count; ++i) {
                    // If not a newline character, increment the size of the data to write
                    if (buffer[i] != '\n') {
                        ++size;
                        continue;
                    }

                    // Skip empty lines
                    if (size == 0) {
                        offset = i + 1;
                        continue;
                    }

                    // Write everything up to the newline to the output stream
                    output.write(buffer + offset, size);

                    // Adjust the offset to continue after the new line character
                    // and reset the output stream
                    offset = i + 1;
                    size = 0;
                    string line = output.str();
                    output.str({});

                    if (options[execution_options::trim_output]) {
                        trim(line);
                    }

                    // Skip empty lines
                    if (line.empty()) {
                        continue;
                    }

                    // Log the line to the output logger
                    log(logger, log_level::debug, line);

                    // Pass the line to the callback
                    if (!callback(line)) {
                        LOG_DEBUG("completed processing output; closing child pipe.");
                        reading = false;
                        break;
                    }
                }
                // Add the remainder of the buffer to the output stream
                if (size > 0) {
                    output.write(buffer + offset, size);
                }
            }

            // Close the read pipe
            // If the child hasn't sent all the data yet, this may signal SIGPIPE on next write
            stdout_read.release();

            string result = output.str();
            if (options[execution_options::trim_output]) {
                trim(result);
            }

            // Log the result and do a final callback call if needed
            if (!result.empty()) {
                log(logger, log_level::debug, result);
                if (callback) {
                    callback(result);
                    result.clear();
                }
            }

            // Wait for the child to exit
            bool success = false;
            int status = 0;
            waitpid(child, &status, 0);
            if (WIFEXITED(status)) {
                status = static_cast<char>(WEXITSTATUS(status));
                LOG_DEBUG("process exited with status code %1%.", status);
                if (status != 0 && options[execution_options::throw_on_nonzero_exit]) {
                    throw child_exit_exception(status, result, "child process returned non-zero exit status.");
                }
                success = status == 0;
            } else if (WIFSIGNALED(status)) {
                status = static_cast<char>(WTERMSIG(status));
                LOG_DEBUG("process was signaled with signal %1%.", status);
                if (options[execution_options::throw_on_signal]) {
                    throw child_signal_exception(status, result, "child process was terminated by signal.");
                }
            }
            return { success, move(result) };
        }

        // Child continues here
        try
        {
            if (dup2(stdin_read, STDIN_FILENO) == -1) {
               throw execution_exception("failed to redirect child stdin.");
            }

            if (dup2(stdout_write, STDOUT_FILENO) == -1) {
               throw execution_exception("failed to redirect child stdout.");
            }

            if (options[execution_options::redirect_stderr]) {
                if (dup2(stdout_write, STDERR_FILENO) == -1) {
                    throw execution_exception("failed to redirect child stderr.");
                }
            } else {
                // Redirect to null
                scoped_descriptor dev_null(open("/dev/null", O_RDONLY));
                if (dev_null < 0 || dup2(dev_null, STDERR_FILENO) == -1) {
                    throw execution_exception("failed to redirect child stderr to null.");
                }
            }

            // Close all open file descriptors up to the limit
            for (decltype(get_max_descriptor_limit()) i = 3; i < get_max_descriptor_limit(); ++i) {
                close(i);
            }

            // Build a vector of pointers to the arguments
            // The first element is the program name
            // The given program arguments then follow
            // The last element is a null to terminate the array
            vector<char const*> args((arguments ? arguments->size() : 0) + 2 /* argv[0] + null */);
            args[0] = file.c_str();
            if (arguments) {
                for (size_t i = 0; i < arguments->size(); ++i) {
                    args[i + 1] = arguments->at(i).c_str();
                }
            }

            // Clear the environment if not merging
            if (!options[execution_options::merge_environment] && environ) {
                *environ = nullptr;
            }

            // Set the locale to C unless specified in the given environment
            if (!environment || environment->count("LC_ALL") == 0) {
                environment::set("LC_ALL", "C");
            }
            if (!environment || environment->count("LANG") == 0) {
                environment::set("LANG", "C");
            }
            if (environment) {
                for (auto const& variable : *environment) {
                    environment::set(variable.first, variable.second);
                }
            }

            // Execute the given program and exit in case of failure
            exit(execv(executable.c_str(), const_cast<char* const*>(args.data())));
        }
        catch (exception& ex)
        {
            // Write out any exception message to "stderr" and exit
            if (options[execution_options::redirect_stderr]) {
                string message = ex.what();
                message += "\n";
                int result = write(STDERR_FILENO, message.c_str(), message.size());
                if (result == -1) {
                    // We don't really care if writing the error message failed
                }
            }
            exit(-1);
        }

        // CHILD DOES NOT RETURN
    }

}}  // namespace facter::executions
