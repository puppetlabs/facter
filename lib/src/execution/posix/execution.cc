#include <facter/execution/execution.hpp>
#include <facter/util/posix/scoped_descriptor.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sstream>

using namespace std;
using namespace facter::util;
using namespace facter::util::posix;
using namespace facter::logging;
using namespace log4cxx;

LOG_DECLARE_NAMESPACE("execution.posix");

// Declare environ for OSX
extern char** environ;

namespace facter { namespace execution {

    execution_exception::execution_exception(string const& message) :
        runtime_error(message)
    {
    }

    execution_failure_exception::execution_failure_exception(string const& output, string const& message) :
        execution_exception(message),
        _output(output)
    {
    }

    string const& execution_failure_exception::output() const
    {
        return _output;
    }

    child_exit_exception::child_exit_exception(int status_code, string const& output, string const& message) :
        execution_failure_exception(output, message),
        _status_code(status_code)
    {
    }

    int child_exit_exception::status_code() const
    {
        return _status_code;
    }

    child_signal_exception::child_signal_exception(int signal, string const& output, string const& message) :
        execution_failure_exception(output, message),
        _signal(signal)
    {
    }

    int child_signal_exception::signal() const
    {
        return _signal;
    }

    void log_execution(string const& file, vector<string> const* arguments)
    {
        if (!LOG_IS_DEBUG_ENABLED()) {
            return;
        }

        ostringstream command_line;
        command_line << file;

        if (arguments) {
            for (auto const& argument : *arguments) {
                command_line << ' ' << argument;
            }
        }
        LOG_DEBUG("Executing command: %1%", command_line.str());
    }

    static string execute(
        string const& file,
        vector<string> const* arguments,
        map<string, string> const* environment,
        function<bool(string&)>* callback,
        option_set<execution_options> const& options);

    string execute(
        string const& file,
        option_set<execution_options> const& options)
    {
        return execute(file, nullptr, nullptr, nullptr, options);
    }

    string execute(
        string const& file,
        vector<string> const& arguments,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, nullptr, nullptr, options);
    }

    string execute(
        string const& file,
        vector<string> const& arguments,
        map<string, string> const& environment,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, &environment, nullptr, options);
    }

    void each_line(
        string const& file,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        execute(file, nullptr, nullptr, &callback, options);
    }

    void each_line(
        string const& file,
        vector<string> const& arguments,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        execute(file, &arguments, nullptr, &callback, options);
    }

    void each_line(
        string const& file,
        vector<string> const& arguments,
        map<string, string> const& environment,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        execute(file, &arguments, &environment, &callback, options);
    }

    string execute(
        string const& file,
        vector<string> const* arguments,
        map<string, string> const* environment,
        function<bool(string&)>* callback,
        option_set<execution_options> const& options)
    {
        log_execution(file, arguments);

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
            auto logger = Logger::getLogger(LOG_ROOT_NAMESPACE "execution.output");

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
                    if (logger->isDebugEnabled()) {
                        log(logger, log_level::debug, line);
                    }

                    // Pass the line to the callback
                    if (!((*callback)(line))) {
                        LOG_DEBUG("Completed processing output; closing child pipe.");
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
                if (logger->isDebugEnabled()) {
                    log(logger, log_level::debug, result);
                }
                if (callback) {
                    (*callback)(result);
                    result.clear();
                }
            }

            // Wait for the child to exit
            int status = 0;
            waitpid(child, &status, 0);
            if (WIFEXITED(status)) {
                status = static_cast<char>(WEXITSTATUS(status));
                LOG_DEBUG("Process exited with status code %1%.", status);
                if (status != 0 && options[execution_options::throw_on_nonzero_exit]) {
                    throw child_exit_exception(status, result, "child process returned non-zero exit status.");
                }
            } else if (WIFSIGNALED(status)) {
                status = static_cast<char>(WTERMSIG(status));
                LOG_DEBUG("Process was signaled with signal %1%.", status);
                if (options[execution_options::throw_on_signal]) {
                    throw child_signal_exception(status, result, "child process was terminated by signal.");
                }
            }
            return result;
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

            // Release the parent descriptors before the exec
            stdin_read.release();
            stdin_write.release();
            stdout_read.release();
            stdout_write.release();

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
                setenv("LC_ALL", "C", 1);
            }
            if (!environment || environment->count("LANG") == 0) {
                setenv("LANG", "C", 1);
            }
            if (environment) {
                for (auto const& variable : *environment) {
                    setenv(variable.first.c_str(), variable.second.c_str(), 1);
                }
            }

            // Execute the given program and exit in case of failure
            exit(execvp(file.c_str(), const_cast<char* const*>(args.data())));
        }
        catch (exception& ex)
        {
            // Write out any exception message to "stderr" and exit
            if (options[execution_options::redirect_stderr]) {
                string message = ex.what();
                message += "\n";
                int result = write(stdout_write, message.c_str(), message.size());
                if (result == -1) {
                    // We don't really care if writing the error message failed
                }
            }
            exit(-1);
        }

        // CHILD DOES NOT RETURN
    }

}}  // namespace facter::executions
