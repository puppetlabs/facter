#ifndef FACTER_FACTS_POSIX_OS_HPP_
#define FACTER_FACTS_POSIX_OS_HPP_

namespace facter { namespace facts { namespace posix {

    /**
     * Stores the constant operating system names.
     */
    struct os
    {
        constexpr static char const* redhat = "RedHat";
        constexpr static char const* centos = "CentOS";
        constexpr static char const* fedora = "Fedora";
        constexpr static char const* scientific = "Scientific";
        constexpr static char const* scientific_cern = "SLC";
        constexpr static char const* ascendos = "Ascendos";
        constexpr static char const* cloud_linux = "CloudLinux";
        constexpr static char const* psbm = "PSBM";
        constexpr static char const* oracle_linux = "OracleLinux";
        constexpr static char const* oracle_vm_linux = "OVS";
        constexpr static char const* oracle_enterprise_linux = "OEL";
        constexpr static char const* amazon = "Amazon";
        constexpr static char const* xen_server = "XenServer";
        constexpr static char const* linux_mint = "LinuxMint";
        constexpr static char const* ubuntu = "Ubuntu";
        constexpr static char const* debian = "Debian";
        constexpr static char const* suse_enterprise_server = "SLES";
        constexpr static char const* suse_enterprise_desktop = "SLED";
        constexpr static char const* open_suse = "OpenSuSE";
        constexpr static char const* suse = "SuSE";
        constexpr static char const* solaris = "Solaris";
        constexpr static char const* nexenta = "Nexenta";
        constexpr static char const* omni = "OmniOS";
        constexpr static char const* open_indiana = "OpenIndiana";
        constexpr static char const* smart = "SmartOS";
        constexpr static char const* gentoo = "Gentoo";
        constexpr static char const* archlinux = "Archlinux";
        constexpr static char const* mandrake = "Mandrake";
        constexpr static char const* mandriva = "Mandriva";
        constexpr static char const* mageia = "Mageia";
        constexpr static char const* openwrt = "OpenWrt";
        constexpr static char const* meego = "MeeGo";
        constexpr static char const* vmware_esx = "VMWareESX";
        constexpr static char const* bluewhite = "Bluewhite64";
        constexpr static char const* slack_amd64 = "Slamd64";
        constexpr static char const* slackware = "Slackware";
        constexpr static char const* alpine = "Alpine";
        constexpr static char const* cumulus = "CumulusLinux";
        constexpr static char const* zen_cloud_platform = "XCP";
        constexpr static char const* kfreebsd = "GNU/kFreeBSD";
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_OS_HPP_
