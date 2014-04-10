#ifndef LIB_INC_FACTS_LINUX_RELEASE_FILE_HPP_
#define LIB_INC_FACTS_LINUX_RELEASE_FILE_HPP_

namespace cfacter { namespace facts { namespace linux {

    /**
     * Stores the constant release file names.
     */
    struct release_file
    {
        constexpr static char const* redhat = "/etc/redhat-release";
        constexpr static char const* fedora = "/etc/fedora-release";
        constexpr static char const* meego = "/etc/meego-release";
        constexpr static char const* oracle_linux = "/etc/oracle-release";
        constexpr static char const* oracle_enterprise_linux = "/etc/enterprise-release";
        constexpr static char const* oracle_vm_linux = "/etc/ovs-release";
        constexpr static char const* debian = "/etc/debian_version";
        constexpr static char const* alpine = "/etc/alpine-release";
        constexpr static char const* suse = "/etc/SuSE-release";
        constexpr static char const* os = "/etc/os-release";
        constexpr static char const* lsb = "/etc/lsb-release";
        constexpr static char const* gentoo = "/etc/gentoo-release";
        constexpr static char const* openwrt = "/etc/openwrt_release";
        constexpr static char const* openwrt_version = "/etc/openwrt_version";
        constexpr static char const* mandriva = "/etc/mandriva-release";
        constexpr static char const* mandrake = "/etc/mandrake-release";
        constexpr static char const* archlinux = "/etc/arch-release";
        constexpr static char const* vmware_esx = "/etc/vmware-release";
        constexpr static char const* bluewhite = "/etc/bluewhite64-version";
        constexpr static char const* slack_amd64 = "/etc/slamd64-version";
        constexpr static char const* slackware = "/etc/slackware-version";
        constexpr static char const* mageia = "/etc/mageia-release";
        constexpr static char const* amazon = "/etc/system-release";
        constexpr static char const* linux_mint_info = "/etc/linuxmint/info";
    };

}}}  // namespace cfacter::facts::linux

#endif  // LIB_INC_FACTS_LINUX_RELEASE_FILE_HPP_
