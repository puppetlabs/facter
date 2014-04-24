#include <execution/execution.hpp>
#include <util/posix/scoped_descriptor.hpp>
#include <util/string.hpp>
#include <logging/logging.hpp>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sstream>

using namespace std;
using namespace cfacter::util;
using namespace cfacter::util::posix;

LOG_DECLARE_NAMESPACE("execution.posix");

namespace cfacter { namespace execution {

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
        vector<string> const* environment,
        option_set<cfacter::execution::execution_options> const& options);

    string execute(
        string const& file,
        option_set<execution_options> const& options)
    {
        return execute(file, nullptr, nullptr, options);
    }

    string execute(
        string const& file,
        vector<string> const& arguments,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, nullptr, options);
    }

    string execute(
        string const& file,
        vector<string> const& arguments,
        vector<string> const& environment,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, &environment, options);
    }

    string execute(
        string const& file,
        vector<string> const* arguments,
        vector<string> const* environment,
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
            // Close the unused descriptors
            stdin_read.release();
            stdout_write.release();

            // TODO: take a vector of bytes to write to stdin?
            stdin_write.release();

            // Read the child output into a string
            ostringstream output;
            char buffer[4096];
            int count;
            do
            {
                count = read(stdout_read, buffer, sizeof(buffer));
                if (count < 0) {
                    throw execution_exception("failed to read child output.");
                }
                output.write(buffer, count);
            }
            while (count > 0);

            // Wait for the child to exit
            string result = output.str();
            int status;
            waitpid(child, &status, 0);
            if (WIFEXITED(status)) {
                status = static_cast<char>(WEXITSTATUS(status));
                LOG_DEBUG("Process exited with status code %1% and output: %2%", status, result);
                if (status != 0 && options[execution_options::throw_on_nonzero_exit]) {
                    throw child_exit_exception(status, result, "child process returned non-zero exit status.");
                }
            } else if (WIFSIGNALED(status)) {
                status = static_cast<char>(WTERMSIG(status));
                LOG_DEBUG("Process was signaled with signal %1% and output: %2%", status, result);
                if (options[execution_options::throw_on_signal]) {
                    throw child_signal_exception(status, result, "child process was terminated by signal.");
                }
            }
            if (options[execution_options::trim_output]) {
                return trim(result);
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

            // TODO: set up environment if specified (execvpe is a GNU extension)
            // TODO: regardless of passed environment variables, we need to force a C locale
            exit(execvp(file.c_str(), const_cast<char* const*>(args.data())));
        }
        catch (exception& ex)
        {
            // Write out any exception message to "stderr" and exit
            if (options[execution_options::redirect_stderr]) {
                string message = ex.what();
                message += "\n";
                write(stdout_write, message.c_str(), message.size());
            }
            exit(-1);
        }

        // CHILD DOES NOT RETURN
    }

}}  // namespace cfacter::executions
