/**
 * @file
 * Declares methods for Facter's integration with the puppet-agent package.
 */
#pragma once

#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <string>

namespace facter { namespace util { namespace agent {
    /**
     * Looks for an executable in Facter's built-in PATH.  Falls back
     * to the system PATH (with a warning) if the requested executable
     * doesn't exist in Facter's PATH.
     * @param exe the name of the executable
     * @return the path to the executable
     */
    inline std::string which(const std::string& exe) {
#ifdef FACTER_PATH
        std::string fixed = leatherman::execution::which(exe, {FACTER_PATH});
        if (!fixed.empty()) {
            return fixed;
        }
        LOG_WARNING("{1} not found at configured location {2}, using PATH instead", exe, FACTER_PATH);
#endif
        return exe;
    }
}}}  // namespace facter::util::agent
