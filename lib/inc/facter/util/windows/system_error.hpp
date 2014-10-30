#pragma once

#include <string>
#include <windows.h>

namespace facter { namespace util { namespace windows {
    /**
     * This is a wrapper for handling error messages on Windows.
     * It returns a formatted string "<error_message> (<error_code>)".
     */
    std::string system_error(DWORD err = GetLastError());
}}}  // namespace facter::util::windows
