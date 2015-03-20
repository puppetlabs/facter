/**
 * @file
 * Declares functions used for executing commands.
 */
#pragma once

#include <string>
#include <functional>

namespace facter { namespace execution {

    /**
     * Reads from a stream closure until there is no more data to read.
     * If a callback is supplied, buffers each line and passes it to the callback.
     * Otherwise, returns the concatenation of the stream.
     * @param trim_output True if output should be trimmed or false if not.
     * @param callback The callback that is called with each line of output.
     * @param yield_input The input stream closure; it expects a mutable string buffer, and returns whether the closure should be invoked again for more input.
     * @return Returns the stream results concatenated together, or an empty string if callback is not null.
     */
    std::string process_stream(bool trim_output, std::function<bool(std::string&)> callback, std::function<bool(std::string&)> yield_input);

}}  // namespace facter::execution
