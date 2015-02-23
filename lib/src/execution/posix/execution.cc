#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/posix/scoped_descriptor.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/ruby/api.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::posix;
using namespace leatherman::logging;
using namespace boost::filesystem;

// Declare environ for OSX
extern char** environ;

namespace facter { namespace execution {

    const char *const command_shell = "sh";
    const char *const command_args = "-c";

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
            // Close the unused descriptors
            stdin_read.release();
            stdout_write.release();
            stdin_write.release();

            string result = process_stream([&](string &buffer) {
                buffer.resize(4096);
                auto count = read(stdout_read, &buffer[0], buffer.size());
                if (count < 0) {
                    if (errno != EINTR) {
                        throw execution_exception("failed to read child output.");
                    }

                    // The call to read was interrupted by a signal before any data was read. Retry read.
                    // See http://www.gnu.org/software/libc/manual/html_node/Interrupted-Primitives.html
                    // This happens in Xcode's debugging.
                    LOG_DEBUG("child pipe read was interrupted and will be retried.");
                    errno = 0;
                    buffer.resize(0);
                    return true;
                }
                buffer.resize(count);
                // Halt if nothing was read.
                return count != 0;
            }, callback, options);

            // Close the read pipe
            // If the child hasn't sent all the data yet, this may signal SIGPIPE on next write
            stdout_read.release();

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
            // Disable Ruby cleanup
            // Ruby doesn't play nice with being forked
            // The VM records the parent pid, so it doesn't like having ruby_cleanup called from a child process
            ruby::api::cleanup = false;

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
                scoped_descriptor dev_null(open("/dev/null", O_RDWR));
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
            execv(executable.c_str(), const_cast<char* const*>(args.data()));
            exit(errno == 0 ? EXIT_FAILURE : errno);
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
            exit(EXIT_FAILURE);
        }

        // CHILD DOES NOT RETURN
    }

}}  // namespace facter::executions
