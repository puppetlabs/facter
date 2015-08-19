/**
 * @file
 * Declares functions used for executing commands.
 */
#pragma once

#include <string>
#include <vector>
#include <map>
#include <tuple>
#include <utility>
#include <stdexcept>
#include <functional>
#include "../util/option_set.hpp"
#include "../util/environment.hpp"
#include "../export.h"

namespace facter { namespace execution {

    /**
     * The supported execution options.
     */
    enum class execution_options
    {
        /**
         * No options.
         */
        none = 0,
        /**
         * Redirect stderr to stdout.  This will override redirect_stderr_to_null if both are set.
         */
        redirect_stderr_to_stdout = (1 << 1),
        /**
         * Throw an exception if the child process exits with a nonzero status.
         */
        throw_on_nonzero_exit = (1 << 2),
        /**
         * Throw an exception if the child process is terminated due to a signal.
         */
        throw_on_signal = (1 << 3),
        /**
         * Automatically trim output leading and trailing whitespace.
         */
        trim_output = (1 << 4),
        /**
         * Merge specified environment with the current process environment.
         */
        merge_environment = (1 << 5),
        /**
         * Redirect stderr to "null".
         */
        redirect_stderr_to_null = (1 << 6),
        /**
         * Preserve (do not quote) arguments.
         */
        preserve_arguments = (1 << 7),
        /**
         * A combination of all throw options.
         */
        throw_on_failure = throw_on_nonzero_exit | throw_on_signal,
    };

    /**
     * System command shell available for executing shell scripts.
     * Uses 'cmd' on Windows and 'sh' on *nix systems.
     */
    extern const char *const command_shell LIBFACTER_EXPORT;

    /**
     * System command shell arguments to accept a script as an argument.
     * Uses '/c' on Windows and '-c' on *nix systems.
     */
    extern const char *const command_args LIBFACTER_EXPORT;

    /**
     * Base class for execution exceptions.
     */
    struct LIBFACTER_EXPORT execution_exception : std::runtime_error
    {
        /**
         * Constructs a execution_exception.
         * @param message The exception message.
         */
        explicit execution_exception(std::string const& message);
    };

    /**
     * Base class for execution failures.
     */
    struct LIBFACTER_EXPORT execution_failure_exception : execution_exception
    {
        /**
         * Constructs a execution_failure_exception.
         * @param message The exception message.
         * @param output The child process stdout output.
         * @param error The child process stderr output.
         */
        execution_failure_exception(std::string const& message, std::string output, std::string error);

        /**
         * Gets the child process stdout output.
         * @return Returns the child process stdout output.
         */
        std::string const& output() const;

        /**
         * Gets the child process stderr output.
         * @return Returns the child process stderr output.
         */
        std::string const& error() const;

     private:
        std::string _output;
        std::string _error;
    };

    /**
     * Exception that is thrown when a child exits with a non-zero status code.
     */
    struct LIBFACTER_EXPORT child_exit_exception : execution_failure_exception
    {
        /**
         * Constructs a child_exit_exception.
         * @param message The exception message.
         * @param status_code The exit status code of the child process.
         * @param output The child process stdout output.
         * @param error The child process stderr output.
         */
        child_exit_exception(std::string const& message, int status_code, std::string output, std::string error);

        /**
         * Gets the child process exit status code.
         * @return Returns the child process exit status code.
         */
        int status_code() const;

     private:
        int _status_code;
    };

    /**
     * Exception that is thrown when a child exists due to a signal.
     */
    struct LIBFACTER_EXPORT child_signal_exception : execution_failure_exception
    {
        /**
         * Constructs a child_signal_exception.
         * @param message The exception message.
         * @param signal The signal code that terminated the child process.
         * @param output The child process stdout output.
         * @param error The child process stderr output.
         */
        child_signal_exception(std::string const& message, int signal, std::string output, std::string error);

        /**
         * Gets the signal that terminated the child process.
         * @return Returns the signal that terminated the child process.
         */
        int signal() const;

     private:
        int _signal;
    };

    /**
     * Exception that is thrown when a command times out.
     */
    struct LIBFACTER_EXPORT timeout_exception : execution_exception
    {
        /**
         * Constructs a timeout_exception.
         * @param message The exception message.
         * @param pid The process id of the process that timed out and was killed.
         */
        timeout_exception(std::string const& message, size_t pid);

        /**
         * Gets the process id of the process that timed out and was killed.
         * @return Returns the process id of the process that timed out and was killed.
         */
        size_t pid() const;

     private:
        size_t _pid;
    };

    /**
     * Searches the given paths for the given executable file.
     * @param file The file to search for.
     * @param directories The directories to search.
     * @return Returns the full path or empty if the file could not be found.
     */
    std::string LIBFACTER_EXPORT which(std::string const& file, std::vector<std::string> const& directories = facter::util::environment::search_paths());

    /**
     * Expands the executable in the command to the full path.
     * @param command The command to expand.
     * @param directories The directories to search.
     * @return Returns the expanded command if the executable was found or empty if it was not found.
     */
    std::string LIBFACTER_EXPORT expand_command(std::string const& command, std::vector<std::string> const& directories = facter::util::environment::search_paths());

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param timeout The timeout, in seconds.  Defaults to no timeout.
     * @param options The execution options.  Defaults to trimming output, merging the environment, and redirecting stderr to null.
     * @return Returns a tuple of whether or not the command succeeded, output from stdout, and output from stderr (if not redirected).
     */
    std::tuple<bool, std::string, std::string> LIBFACTER_EXPORT execute(
        std::string const& file,
        uint32_t timeout = 0,
        facter::util::option_set<execution_options> const& options = { execution_options::trim_output, execution_options::merge_environment, execution_options::redirect_stderr_to_null });

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param timeout The timeout, in seconds. Defaults to no timeout.
     * @param options The execution options.  Defaults to trimming output, merging the environment, and redirecting stderr to null.
     * @return Returns a tuple of whether or not the command succeeded, output from stdout, and output from stderr (if not redirected).
     */
    std::tuple<bool, std::string, std::string> LIBFACTER_EXPORT execute(
        std::string const& file,
        std::vector<std::string> const& arguments,
        uint32_t timeout = 0,
        facter::util::option_set<execution_options> const& options = { execution_options::trim_output, execution_options::merge_environment, execution_options::redirect_stderr_to_null });

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param environment The environment variables to pass to the child process.
     * @param timeout The timeout, in seconds. Defaults to no timeout.
     * @param options The execution options.  Defaults to trimming output, merging the environment, and redirecting stderr to null.
     * @return Returns a tuple of whether or not the command succeeded, output from stdout, and output from stderr (if not redirected).
     */
    std::tuple<bool, std::string, std::string> LIBFACTER_EXPORT execute(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::map<std::string, std::string> const& environment,
        uint32_t timeout = 0,
        facter::util::option_set<execution_options> const& options = { execution_options::trim_output, execution_options::merge_environment, execution_options::redirect_stderr_to_null });

    /**
     * Executes the given program and returns each line of output.
     * @param file The name or path of the program to execute.
     * @param stdout_callback The callback that is called with each line of output on stdout.
     * @param stderr_callback The callback that is called with each line of output on stderr. If nullptr, implies redirect_stderr_to_null unless redirect_stderr_to_stdout is set in options.
     * @param timeout The timeout, in seconds. Defaults to no timeout.
     * @param options The execution options.  Defaults to trimming output and merging the environment.
     * @return Returns true if the execution succeeded or false if it did not.
     */
    bool LIBFACTER_EXPORT each_line(
        std::string const& file,
        std::function<bool(std::string&)> stdout_callback,
        std::function<bool(std::string&)> stderr_callback = nullptr,
        uint32_t timeout = 0,
        facter::util::option_set<execution_options> const& options = { execution_options::trim_output, execution_options::merge_environment });

    /**
     * Executes the given program and returns each line of output.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param stdout_callback The callback that is called with each line of output on stdout.
     * @param stderr_callback The callback that is called with each line of output on stderr. If nullptr, implies redirect_stderr_to_null unless redirect_stderr_to_stdout is set in options.
     * @param timeout The timeout, in seconds. Defaults to no timeout.
     * @param options The execution options.  Defaults to trimming output and merging the environment.
     * @return Returns true if the execution succeeded or false if it did not.
     */
    bool LIBFACTER_EXPORT each_line(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::function<bool(std::string&)> stdout_callback,
        std::function<bool(std::string&)> stderr_callback = nullptr,
        uint32_t timeout = 0,
        facter::util::option_set<execution_options> const& options = { execution_options::trim_output, execution_options::merge_environment });

    /**
     * Executes the given program and returns each line of output.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param environment The environment variables to pass to the child process.
     * @param stdout_callback The callback that is called with each line of output on stdout.
     * @param stderr_callback The callback that is called with each line of output on stderr. If nullptr, implies redirect_stderr_to_null unless redirect_to_stdout is set in options.
     * @param timeout The timeout, in seconds. Defaults to no timeout.
     * @param options The execution options.  Defaults to trimming output and merging the environment.
     * @return Returns true if the execution succeeded or false if it did not.
     */
    bool LIBFACTER_EXPORT each_line(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::map<std::string, std::string> const& environment,
        std::function<bool(std::string&)> stdout_callback,
        std::function<bool(std::string&)> stderr_callback = nullptr,
        uint32_t timeout = 0,
        facter::util::option_set<execution_options> const& options = { execution_options::trim_output, execution_options::merge_environment });

}}  // namespace facter::execution
