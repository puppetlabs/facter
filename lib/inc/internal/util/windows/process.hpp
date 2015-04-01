/**
 * @file
 * Declares utility functions for querying process properties
 */
#pragma once

namespace facter { namespace util { namespace windows { namespace process {

    /**
     * Returns whether or not the OS has the ability to set elevated token information.
     * @return True on Windows Vista or later, otherwise false.
     */
    bool supports_elevated_security();

    /**
     * Returns whether or not the owner of the current process is running with elevated security privileges.
     * Only supported on Windows Vista or later.
     * @return True if elevated, otherwise false.
     */
    bool has_elevated_security();

}}}}  // namespace facter::util::windows::process
