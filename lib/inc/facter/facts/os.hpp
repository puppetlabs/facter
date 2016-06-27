/**
 * @file
 * Declares the operating system constants.
 */
#pragma once

#include "../export.h"

namespace facter { namespace facts {

    /**
     * Stores the constant operating system names.
     */
    struct LIBFACTER_EXPORT os
    {
        /**
         * The RedHat operating system.
         */
        constexpr static char const* redhat = "RedHat";
        /**
         * The Centos operating system.
         */
        constexpr static char const* centos = "CentOS";
        /**
         * The Fedora operating system.
         */
        constexpr static char const* fedora = "Fedora";
        /**
         * The Scientific Linux operating system.
         */
        constexpr static char const* scientific = "Scientific";
        /**
         * The Scientific Linux CERN operating system.
         */
        constexpr static char const* scientific_cern = "SLC";
        /**
         * The Ascendos Linux operating system.
         */
        constexpr static char const* ascendos = "Ascendos";
        /**
         * The Cloud Linux operating system.
         */
        constexpr static char const* cloud_linux = "CloudLinux";
        /**
         * The Parallels Server Bare Metal operating system.
         */
        constexpr static char const* psbm = "PSBM";
        /**
         * The Oracle Linux operating system.
         */
        constexpr static char const* oracle_linux = "OracleLinux";
        /**
         * The Oracle VM Linux operating system.
         */
        constexpr static char const* oracle_vm_linux = "OVS";
        /**
         * The Oracle Enterprise Linux operating system.
         */
        constexpr static char const* oracle_enterprise_linux = "OEL";
        /**
         * The Amazon Linux operating system.
         */
        constexpr static char const* amazon = "Amazon";
        /**
         * The Xen Server Linux operating system.
         */
        constexpr static char const* xen_server = "XenServer";
        /**
         * The Mint Linux operating system.
         */
        constexpr static char const* linux_mint = "LinuxMint";
        /**
         * The Ubuntu Linux operating system.
         */
        constexpr static char const* ubuntu = "Ubuntu";
        /**
         * The Debian Linux operating system.
         */
        constexpr static char const* debian = "Debian";
        /**
         * The SuSE Linux Enterprise Server operating system.
         */
        constexpr static char const* suse_enterprise_server = "SLES";
        /**
         * The SuSE Linux Enterprise Desktop operating system.
         */
        constexpr static char const* suse_enterprise_desktop = "SLED";
        /**
         * The Open SuSE operating system.
         */
        constexpr static char const* open_suse = "OpenSuSE";
        /**
         * The SuSE operating system.
         */
        constexpr static char const* suse = "SuSE";
        /**
         * The Solaris operating system.
         */
        constexpr static char const* solaris = "Solaris";
        /**
         * The SunOS operating system.
         */
        constexpr static char const* sunos = "SunOS";
        /**
         * The Nexenta operating system.
         */
        constexpr static char const* nexenta = "Nexenta";
        /**
         * The Omni operating system.
         */
        constexpr static char const* omni = "OmniOS";
        /**
         * The Open Indiana operating system.
         */
        constexpr static char const* open_indiana = "OpenIndiana";
        /**
         * The SmartOS operating system.
         */
        constexpr static char const* smart = "SmartOS";
        /**
         * The Gentoo Linux operating system.
         */
        constexpr static char const* gentoo = "Gentoo";
        /**
         * The Archlinux operating system.
         */
        constexpr static char const* archlinux = "Archlinux";
        /**
         * The Manjaro Linux operating system.
         */
        constexpr static char const* manjarolinux = "ManjaroLinux";
        /**
         * The Mandrake Linux operating system.
         */
        constexpr static char const* mandrake = "Mandrake";
        /**
         * The Mandriva Linux operating system.
         */
        constexpr static char const* mandriva = "Mandriva";
        /**
         * The Mageia Linux operating system.
         */
        constexpr static char const* mageia = "Mageia";
        /**
         * The Open WRT operating system.
         */
        constexpr static char const* openwrt = "OpenWrt";
        /**
         * The Meego operating system.
         */
        constexpr static char const* meego = "MeeGo";
        /**
         * The VMWare ESX operating system.
         */
        constexpr static char const* vmware_esx = "VMWareESX";
        /**
         * The Slackware Linux operating system.
         */
        constexpr static char const* slackware = "Slackware";
        /**
         * The Alpine Linux operating system.
         */
        constexpr static char const* alpine = "Alpine";
        /**
         * The CoreOS Linux operating system.
         */
        constexpr static char const* coreos = "CoreOS";
        /**
         * The Cumulus Linux operating system.
         */
        constexpr static char const* cumulus = "CumulusLinux";
        /**
         * The Zen Cloud Platform linux operating system.
         */
        constexpr static char const* zen_cloud_platform = "XCP";
        /**
         * The GNU/kFreeBSD operating system.
         */
        constexpr static char const* kfreebsd = "GNU/kFreeBSD";
        /**
         * The Windows operating system.
         */
        constexpr static char const* windows = "windows";
        /**
         * The AristaEOS operating system.
         */
        constexpr static char const* arista_eos = "AristaEOS";
       /**
        * The HuaweiOS operating system.
        */
        constexpr static char const* huawei = "HuaweiOS";
       /**
        * The PhotonOS operating system.
        */
        constexpr static char const* photon_os = "PhotonOS";
    };

}}
