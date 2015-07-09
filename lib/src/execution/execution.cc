#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>

#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>

using namespace std;
using namespace leatherman::logging;
using namespace boost::filesystem;
using namespace boost::algorithm;

namespace lth_exec = leatherman::execution;

namespace facter { namespace execution {

    execution_exception::execution_exception(string const& message) :
        runtime_error(message)
    {
    }

    execution_failure_exception::execution_failure_exception(string const& message, string output, string error) :
        execution_exception(message),
        _output(move(output)),
        _error(move(error))
    {
    }

    string const& execution_failure_exception::output() const
    {
        return _output;
    }

    string const& execution_failure_exception::error() const
    {
        return _error;
    }

    child_exit_exception::child_exit_exception(string const& message, int status_code, string output, string error) :
        execution_failure_exception(message, move(output), move(error)),
        _status_code(status_code)
    {
    }

    int child_exit_exception::status_code() const
    {
        return _status_code;
    }

    child_signal_exception::child_signal_exception(string const& message, int signal, string output, string error) :
        execution_failure_exception(message, move(output), move(error)),
        _signal(signal)
    {
    }

    int child_signal_exception::signal() const
    {
        return _signal;
    }

    timeout_exception::timeout_exception(string const& message, size_t pid) :
        execution_exception(message),
        _pid(pid)
    {
    }

    size_t timeout_exception::pid() const
    {
        return _pid;
    }

    string expand_command(string const& command, vector<string> const& directories)
    {
        return lth_exec::expand_command(command, directories);
    }

    tuple<bool, string, string> execute(
        string const& file,
        uint32_t timeout,
        lth_util::option_set<lth_exec::execution_options> const& options)
    {
        return lth_exec::execute(file, timeout, options);
    }

    tuple<bool, string, string> execute(
        string const& file,
        vector<string> const& arguments,
        uint32_t timeout,
        lth_util::option_set<lth_exec::execution_options> const& options)
    {
        return lth_exec::execute(file, arguments, timeout, options);
    }

    tuple<bool, string, string> execute(
        string const& file,
        vector<string> const& arguments,
        map<string, string> const& environment,
        uint32_t timeout,
        lth_util::option_set<lth_exec::execution_options> const& options)
    {
        return lth_exec::execute(file, arguments, environment, timeout, options);
    }

    bool each_line(
        string const& file,
        function<bool(string&)> stdout_callback,
        function<bool(string&)> stderr_callback,
        uint32_t timeout,
        lth_util::option_set<lth_exec::execution_options> const& options)
    {
        return lth_exec::each_line(file, stdout_callback, stderr_callback, timeout, options);
    }

    bool each_line(
        string const& file,
        vector<string> const& arguments,
        function<bool(string&)> stdout_callback,
        function<bool(string&)> stderr_callback,
        uint32_t timeout,
        lth_util::option_set<lth_exec::execution_options> const& options)
    {
        return lth_exec::each_line(file, arguments, stdout_callback, stderr_callback, timeout, options);
    }

    bool each_line(
        string const& file,
        vector<string> const& arguments,
        map<string, string> const& environment,
        function<bool(string&)> stdout_callback,
        function<bool(string&)> stderr_callback,
        uint32_t timeout,
        lth_util::option_set<lth_exec::execution_options> const& options)
    {
        return lth_exec::each_line(file, arguments, environment, stdout_callback, stderr_callback, timeout, options);
    }

    tuple<string, string> process_streams(bool trim, function<bool(string&)> const& stdout_callback, function<bool(string&)> const& stderr_callback, function<void(function<bool(string const&)>, function<bool(string const&)>)> const& read_streams)
    {
        return lth_exec::process_streams(trim, stdout_callback, stderr_callback, read_streams);
    }

}}  // namespace facter::executions
