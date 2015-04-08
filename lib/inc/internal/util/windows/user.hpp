/**
 * @file
 * Declares utility functions for querying user properties
 */
#pragma once

#include <string>

namespace facter { namespace util { namespace windows { namespace user {

    /**
     * Determines whether the current process has Administrator privileges and can be expected to succeed at
     * tasks restricted to Administrators.
     * @return True if the current process has Administrator privileges, otherwise false.
     */
    bool is_admin();

    /**
     * Query token membership to determine whether the current user is a member of the Administrators group.
     * @return True if user is an Administrator, otherwise false.
     */
    bool check_token_membership();

    /**
     * Finds the user's home directory in a Ruby-compatible way.
     * @return The home directory, trying %HOME% > %HOMEDRIVE%%HOMEPATH% > %USERPROFILE%
     */
    std::string home_dir();

}}}}  // namespace facter::util::windows::user
