/**
 * @file
 * Declares functions used for executing commands.
 */
#pragma once

#include <string>
#include <functional>
#include <facter/execution/execution.hpp>
#include <facter/util/option_set.hpp>

namespace facter { namespace execution {

    /**
     * Reads from a stream closure until there is no more data to read.
     * If a callback is supplied, buffers each line and passes it to the callback.
     * Otherwise, returns the concatenation of the stream.
     * @param yield_input The input stream closure; it expects a mutable string buffer, and returns whether the closure should be invoked again for more input.
     * @param callback The callback that is called with each line of output.
     * @param options The execution options.
     * @return Returns the stream results concatenated together, or an empty string if callback is not null.
     */
    std::string process_stream(
        std::function<bool(std::string&)> yield_input,
        std::function<bool(std::string&)> callback,
        facter::util::option_set<execution_options> const& options = { execution_options::defaults });

}}  // namespace facter::execution
