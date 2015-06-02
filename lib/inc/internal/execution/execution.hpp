/**
 * @file
 * Declares functions used for executing commands.
 */
#pragma once

#include <string>
#include <functional>

namespace facter { namespace execution {

    /**
     * Processes stdout and stderror streams of a child process.
     * @param trim True if output should be trimmed or false if not.
     * @param stdout_callback The callback to use when a line is read for stdout.
     * @param stderr_callback The callback to use when a line is read for stdout.
     * @param read_streams The callback that is called to read stdout and stderr streams.
     * @return Returns a tuple of stdout and stderr output.  If stdout_callback or stderr_callback is given, it will return empty strings.
     */
    std::tuple<std::string, std::string> process_streams(
        bool trim,
        std::function<bool(std::string&)> const& stdout_callback,
        std::function<bool(std::string&)> const& stderr_callback,
        std::function<void(std::function<bool(std::string const&)>, std::function<bool(std::string const&)>)> const& read_streams);

}}  // namespace facter::execution
