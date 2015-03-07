/**
 * @file
 * Declares functions used for executing commands.
 */
#pragma once

#include <string>
#include <vector>
#include <map>
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
         * Redirect stderr to stdout.  If not specified, stderr is redirected
         * to null.
         */
        redirect_stderr = (1 << 1),
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
         * A combination of all throw options.
         */
        throw_on_failure = throw_on_nonzero_exit |  throw_on_signal,
        /**
         * The default execution options.
         */
        defaults = trim_output | merge_environment,
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
         * @param output The child process output.
         * @param message The exception message.
         */
        execution_failure_exception(std::string const& output, std::string const& message);

        /**
         * Gets the child process output.
         * @return Returns the child process output.
         */
        std::string const& output() const;

     private:
        std::string _output;
    };

    /**
     * Exception that is thrown when a child exits with a non-zero status code.
     */
    struct LIBFACTER_EXPORT child_exit_exception : execution_failure_exception
    {
        /**
         * Constructs a child_exit_exception.
         * @param status_code The exit status code of the child process.
         * @param output The child process output.
         * @param message The exception message.
         */
        child_exit_exception(int status_code, std::string const& output, std::string const& message);

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
         * @param signal The signal code that terminated the child process.
         * @param output The child process output.
         * @param message The exception message.
         */
        child_signal_exception(int signal, std::string const& output, std::string const& message);

        /**
         * Gets the signal that terminated the child process.
         * @return Returns the signal that terminated the child process.
         */
        int signal() const;

     private:
        int _signal;
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
     * @return Returns the expanded command if the executable was found or the original command if not.
     */
    std::string LIBFACTER_EXPORT expand_command(std::string const& command, std::vector<std::string> const& directories = facter::util::environment::search_paths());

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param options The execution options.
     * @return Returns whether or not the execution succeeded paired with the child process output.
     */
    std::pair<bool, std::string> LIBFACTER_EXPORT execute(
        std::string const& file,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param options The execution options.
     * @return Returns whether or not the execution succeeded paired with the child process output.
     */
    std::pair<bool, std::string> LIBFACTER_EXPORT execute(
        std::string const& file,
        std::vector<std::string> const& arguments,
        facter::util::option_set<execution_options> const& options  = { execution_options::defaults });

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param environment The environment variables to pass to the child process.
     * @param options The execution options.
     * @return Returns whether or not the execution succeeded paired with the child process output.
     */
    std::pair<bool, std::string> LIBFACTER_EXPORT execute(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::map<std::string, std::string> const& environment,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

    /**
     * Executes the given program and returns each line of output.
     * @param file The name or path of the program to execute.
     * @param callback The callback that is called with each line of output.
     * @param options The execution options.
     * @return Returns true if the execution succeeded or false if it did not.
     */
    bool LIBFACTER_EXPORT each_line(
        std::string const& file,
        std::function<bool(std::string&)> callback,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

    /**
     * Executes the given program and returns each line of output.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param callback The callback that is called with each line of output.
     * @param options The execution options.
     * @return Returns true if the execution succeeded or false if it did not.
     */
    bool LIBFACTER_EXPORT each_line(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::function<bool(std::string&)> callback,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

    /**
     * Executes the given program and returns each line of output.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program. On Windows they will be quoted as needed for spaces.
     * @param environment The environment variables to pass to the child process.
     * @param callback The callback that is called with each line of output.
     * @param options The execution options.
     * @return Returns true if the execution succeeded or false if it did not.
     */
    bool LIBFACTER_EXPORT each_line(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::map<std::string, std::string> const& environment,
        std::function<bool(std::string&)> callback,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

    /**
     * Reads from a stream closure until there is no more data to read.
     * If a callback is supplied, buffers each line and passes it to the callback.
     * Otherwise, returns the concatenation of the stream.
     * @param yield_input The input stream closure; it expects a mutable string buffer, and returns whether the closure should be invoked again for more input.
     * @param callback The callback that is called with each line of output.
     * @param options The execution options.
     * @return Returns the stream results concatenated together, or an empty string if callback is not null.
     */
    std::string LIBFACTER_EXPORT process_stream(
        std::function<bool(std::string&)> yield_input,
        std::function<bool(std::string&)> callback,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

}}  // namespace facter::execution
