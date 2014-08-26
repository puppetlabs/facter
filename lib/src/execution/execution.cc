#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>

using namespace std;
using namespace facter::util;
using namespace facter::logging;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("execution.windows");

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
        LOG_DEBUG("executing command: %1%", command_line.str());
    }

    string expand_command(string const& command, vector<string> const& directories)
    {
        string result = command;
        trim(result);

        if (result.empty()) {
            return result;
        }

        string quote = result[0] == '"' || result[0] == '\'' ? string(1, result[0]) : "";
        string file;
        string remainder;
        if (!quote.empty()) {
            // Look for the ending quote for the command
            auto pos = result.find(result[0], 1);
            if (pos == string::npos) {
                // No closing quote
                file = result.substr(1);
            } else {
                file = result.substr(1, pos - 1);
                remainder = result.substr(pos);
            }
        } else {
            auto pos = command.find(' ');
            if (pos == string::npos) {
                file = result;
            } else {
                file = result.substr(0, pos);
                remainder = result.substr(pos);
            }
        }

        file = which(file, directories);
        if (file.empty()) {
            return result;
        }
        return quote + file + remainder;
    }

    pair<bool, string> execute(
        string const& file,
        vector<string> const* arguments,
        map<string, string> const* environment,
        function<bool(string&)> callback,
        option_set<execution_options> const& options);

    pair<bool, string> execute(
        string const& file,
        option_set<execution_options> const& options)
    {
        return execute(file, nullptr, nullptr, nullptr, options);
    }

    pair<bool, string> execute(
        string const& file,
        vector<string> const& arguments,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, nullptr, nullptr, options);
    }

    pair<bool, string> execute(
        string const& file,
        vector<string> const& arguments,
        map<string, string> const& environment,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, &environment, nullptr, options);
    }

    bool each_line(
        string const& file,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        return execute(file, nullptr, nullptr, callback, options).first;
    }

    bool each_line(
        string const& file,
        vector<string> const& arguments,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, nullptr, callback, options).first;
    }

    bool each_line(
        string const& file,
        vector<string> const& arguments,
        map<string, string> const& environment,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        return execute(file, &arguments, &environment, callback, options).first;
    }

}}  // namespace facter::executions
