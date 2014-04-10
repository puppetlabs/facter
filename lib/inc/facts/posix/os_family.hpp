#ifndef LIB_INC_FACTS_POSIX_OS_FAMILY_HPP_
#define LIB_INC_FACTS_POSIX_OS_FAMILY_HPP_

namespace cfacter { namespace facts { namespace posix {

    /**
     * Stores the constant operating system family names.
     */
    struct os_family
    {
        constexpr static char const* redhat = "RedHat";
        constexpr static char const* debian = "Debian";
        constexpr static char const* suse = "Suse";
        constexpr static char const* solaris = "Solaris";
        constexpr static char const* gentoo = "Gentoo";
        constexpr static char const* archlinux = "Archlinux";
        constexpr static char const* mandrake = "Mandrake";
    };

}}}  // namespace cfacter::facts::posix

#endif  // LIB_INC_FACTS_POSIX_OS_FAMILY_HPP_
