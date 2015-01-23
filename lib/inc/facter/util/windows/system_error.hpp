/**
 * @file
 * Declares utility functions for getting Windows error messages.
 */
#pragma once

#include <string>

namespace facter { namespace util { namespace windows {
    /**
     * This is a wrapper for printing error messages on Windows.
     * @param err The Windows error code.
     * @return A formatted string "<error_message> (<error_code>)".
     */
    std::string system_error(unsigned long err);

    /**
     * This is a wrapper for printing error messages on Windows.
     * It calls system_error with GetLastError as the argument.
     * @return A formatted string "<error_message> (<error_code>)".
     */
    std::string system_error();
}}}  // namespace facter::util::windows
