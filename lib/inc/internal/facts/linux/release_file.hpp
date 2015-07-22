/**
 * @file
 * Declares the Linux release file constants.
 */
#pragma once

namespace facter { namespace facts { namespace linux {

    /**
     * Stores the constant release file names.
     */
    struct release_file
    {
        /**
         * Release file for RedHat Linux.
         */
        constexpr static char const* redhat = "/etc/redhat-release";
        /**
         * Release file for Fedora.
         */
        constexpr static char const* fedora = "/etc/fedora-release";
        /**
         * Release file for Meego.
         */
        constexpr static char const* meego = "/etc/meego-release";
        /**
         * Release file for Oracle Linux.
         */
        constexpr static char const* oracle_linux = "/etc/oracle-release";
        /**
         * Release file for Oracle Enterprise Linux.
         */
        constexpr static char const* oracle_enterprise_linux = "/etc/enterprise-release";
        /**
         * Release file for Oracle VM Linux.
         */
        constexpr static char const* oracle_vm_linux = "/etc/ovs-release";
        /**
         * Version file for Debian Linux.
         */
        constexpr static char const* debian = "/etc/debian_version";
        /**
         * Release file for Alpine Linux.
         */
        constexpr static char const* alpine = "/etc/alpine-release";
        /**
         * Release file for SuSE Linux.
         */
        constexpr static char const* suse = "/etc/SuSE-release";
        /**
         * Release file for generic Linux distros.
         * Also used for:
         * - Cisco
         * - CoreOS
         * - Cumulus
         */
        constexpr static char const* os = "/etc/os-release";
        /**
         * Release file for LSB distros.
         */
        constexpr static char const* lsb = "/etc/lsb-release";
        /**
         * Release file for Gentoo Linux.
         */
        constexpr static char const* gentoo = "/etc/gentoo-release";
        /**
         * Release file for Open WRT.
         */
        constexpr static char const* openwrt = "/etc/openwrt_release";
        /**
         * Version file for Open WRT.
         */
        constexpr static char const* openwrt_version = "/etc/openwrt_version";
        /**
         * Release file for Mandriva Linux.
         */
        constexpr static char const* mandriva = "/etc/mandriva-release";
        /**
         * Release file for Mandrake Linux.
         */
        constexpr static char const* mandrake = "/etc/mandrake-release";
        /**
         * Release file for Archlinux.
         */
        constexpr static char const* archlinux = "/etc/arch-release";
        /**
         * Release file for VMWare ESX Linux.
         */
        constexpr static char const* vmware_esx = "/etc/vmware-release";
        /**
         * Version file for Slackware Linux.
         */
        constexpr static char const* slackware = "/etc/slackware-version";
        /**
         * Release file for Mageia Linux.
         */
        constexpr static char const* mageia = "/etc/mageia-release";
        /**
         * Release file for Amazon Linux.
         */
        constexpr static char const* amazon = "/etc/system-release";
        /**
         * Release file for Mint Linux.
         */
        constexpr static char const* linux_mint_info = "/etc/linuxmint/info";
        /**
         * Release file for AristaEOS.
         */
        constexpr static char const* arista_eos = "/etc/Eos-release";
    };

}}}  // namespace facter::facts::linux
