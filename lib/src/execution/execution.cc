#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>

using namespace std;
using namespace facter::util;
using namespace facter::logging;
using namespace boost::filesystem;
using namespace boost::algorithm;

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
        boost::trim(result);

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

    string process_stream(
        function<bool(string&)> yield_input,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        // Get a special logger used specifically for child process output
        const std::string logger = "|";

        // Read output until it stops.
        string output, buffer;
        bool reading = true;
        while (reading) {
            if (!yield_input(buffer)) {
                // Nothing to read, processing is complete.
                break;
            } else if (buffer.size() == 0) {
                // No data read, but continue. If it were a halting error, an exception was thrown.
                continue;
            }

            if (!callback) {
                // If given no callback, buffer the entire output
                output.append(buffer);
                continue;
            }

            // Find the last newline, because anything after may not be a complete line.
            auto lastNL = buffer.find_last_of("\n\r");
            if (lastNL == string::npos) {
                // No newline found, so keep appending and continue.
                output.append(buffer);
                continue;
            }

            // Make a range for iterating through lines.
            auto str_range = make_pair(buffer.begin(), buffer.begin()+lastNL);
            auto line_iterator = boost::make_iterator_range(
                make_split_iterator(str_range, token_finder(is_any_of("\n\r"), token_compress_on)),
                split_iterator<string::iterator>());

            for (auto &line : line_iterator) {
                // The previous trailing data is picked up by default.
                output.append(line.begin(), line.end());

                if (options[execution_options::trim_output]) {
                    boost::trim(output);
                }

                // Skip empty lines
                if (output.empty()) {
                    continue;
                }

                // Log the line to the output logger
                if (LOG_IS_DEBUG_ENABLED()) {
                    log(logger, log_level::debug, output);
                }

                // Pass the line to the callback
                if (!callback(output)) {
                    LOG_DEBUG("completed processing output; closing child pipe.");
                    reading = false;
                    break;
                }

                // Clear the line for the next iteration. Doing this allows us to
                // append in the 1st iteration without a conditional check.
                output.clear();
            }

            // Save the new trailing data
            output.assign(buffer.begin()+lastNL, buffer.end());
        }

        // Log the result and do a final callback if needed.
        if (options[execution_options::trim_output]) {
            boost::trim(output);
        }

        if (!output.empty()) {
            if (LOG_IS_DEBUG_ENABLED()) {
                log(logger, log_level::debug, output);
            }
            if (callback) {
                callback(output);
                return {};
            }
        }
        return output;
    }

}}  // namespace facter::executions
