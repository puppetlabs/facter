#ifndef LIB_INC_EXECUTION_EXECUTION_HPP_
#define LIB_INC_EXECUTION_EXECUTION_HPP_

#include <string>
#include <vector>
#include <stdexcept>
#include "../util/option_set.hpp"

namespace cfacter { namespace execution {

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
         * A combination of all throw options.
         */
        throw_on_failure = throw_on_nonzero_exit |  throw_on_signal,
        /**
         * The default execution options.
         */
        defaults = redirect_stderr | trim_output| throw_on_failure,
    };

    /**
     * Base class for execution exceptions.
     */
    struct execution_exception : std::runtime_error
    {
        /**
         * Constructs a execution_exception.
         * @param message The exception message.
         */
        explicit execution_exception(std::string const& message) : std::runtime_error(message) {}
    };

    /**
     * Base class for execution failures.
     */
    struct execution_failure_exception : std::runtime_error
    {
        /**
         * Constructs a execution_failure_exception.
         * @param output The child process output.
         * @param message The exception message.
         */
        execution_failure_exception(std::string const& output, std::string const& message) :
            std::runtime_error(message),
            _output(output)
        {
        }

        /**
         * Gets the child process output.
         * @return Returns the child process output.
         */
        std::string const& output() const { return _output; }

     private:
        std::string _output;
    };

    /**
     * Exception that is thrown when a child exits with a non-zero status code.
     */
    struct child_exit_exception : execution_failure_exception
    {
        /**
         * Constructs a child_exit_exception.
         * @param status_code The exit status code of the child process.
         * @param output The child process output.
         * @param message The exception message.
         */
        child_exit_exception(int status_code, std::string const& output, std::string const& message) :
            execution_failure_exception(output, message),
            _status_code(status_code)
        {
        }

        /**
         * Gets the child process exit status code.
         * @return Returns the child process exit status code.
         */
        int status_code() const { return _status_code; }

     private:
        int _status_code;
    };

    /**
     * Exception that is thrown when a child exists due to a signal.
     */
    struct child_signal_exception : execution_failure_exception
    {
        /**
         * Constructs a child_signal_exception.
         * @param signal The signal code that terminated the child process.
         * @param output The child process output.
         * @param message The exception message.
         */
        child_signal_exception(int signal, std::string const& output, std::string const& message) :
            execution_failure_exception(output, message),
            _signal(signal)
        {
        }

        /**
         * Gets the signal that terminated the child process.
         * @return Returns the signal that terminated the child process.
         */
        int signal() const { return _signal; }

     private:
        int _signal;
    };

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param options The execution options.
     * @return Returns the child process output.
     */
    std::string execute(
        std::string const& file,
        cfacter::util::option_set<execution_options> const& options = { execution_options::defaults });

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program.
     * @param options The execution options.
     * @return Returns the child process output.
     */
    std::string execute(
        std::string const& file,
        std::vector<std::string> const& arguments,
        cfacter::util::option_set<execution_options> const& options  = { execution_options::defaults });

    /**
     * Executes the given program.
     * @param file The name or path of the program to execute.
     * @param arguments The arguments to pass to the program.
     * @param environment The environment variables to pass to the child process.
     * @param options The execution options.
     * @return Returns the child process output.
     */
    std::string execute(
        std::string const& file,
        std::vector<std::string> const& arguments,
        std::vector<std::string> const& environment,
        cfacter::util::option_set<execution_options> const& options = { execution_options::defaults });

}}  // namespace cfacter::execution

#endif  // LIB_INC_EXECUTION_EXECUTION_HPP_

