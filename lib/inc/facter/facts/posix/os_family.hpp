/**
 * @file
 * Declares the POSIX operating system family constants.
 */
#ifndef FACTER_FACTS_POSIX_OS_FAMILY_HPP_
#define FACTER_FACTS_POSIX_OS_FAMILY_HPP_

namespace facter { namespace facts { namespace posix {

    /**
     * Stores the constant operating system family names.
     */
    struct os_family
    {
        /**
         * The RedHat family of operating systems.
         */
        constexpr static char const* redhat = "RedHat";
        /**
         * The Debian family of operating systems.
         */
        constexpr static char const* debian = "Debian";
        /**
         * The SuSE family of operating systems.
         */
        constexpr static char const* suse = "Suse";
        /**
         * The Solaris family of operating systems.
         */
        constexpr static char const* solaris = "Solaris";
        /**
         * The SunOS family of operating systems.
         */
        constexpr static char const* sunos = "SunOS";
        /**
         * The Gentoo family of operating systems.
         */
        constexpr static char const* gentoo = "Gentoo";
        /**
         * The Archlinux family of operating systems.
         */
        constexpr static char const* archlinux = "Archlinux";
        /**
         * The Mandrake family of operating systems.
         */
        constexpr static char const* mandrake = "Mandrake";
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_OS_FAMILY_HPP_
