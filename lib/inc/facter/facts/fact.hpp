#ifndef FACTER_FACTS_FACT_HPP_
#define FACTER_FACTS_FACT_HPP_

namespace facter { namespace facts {

    /**
     * Stores the constant fact names.
     */
    struct fact
    {
        constexpr static char const* kernel = "kernel";
        constexpr static char const* kernel_version = "kernelversion";
        constexpr static char const* kernel_release = "kernelrelease";
        constexpr static char const* kernel_major_version = "kernelmajversion";
        constexpr static char const* operating_system = "operatingsystem";
        constexpr static char const* os_family = "osfamily";
        constexpr static char const* operating_system_release = "operatingsystemrelease";
        constexpr static char const* operating_system_major_release = "operatingsystemmajrelease";
        constexpr static char const* hostname = "hostname";
        constexpr static char const* lsb_dist_id = "lsbdistid";
        constexpr static char const* lsb_dist_release = "lsbdistrelease";
        constexpr static char const* lsb_dist_codename = "lsbdistcodename";
        constexpr static char const* lsb_dist_description = "lsbdistdescription";
        constexpr static char const* lsb_dist_major_release = "lsbmajdistrelease";
        constexpr static char const* lsb_dist_minor_release = "lsbminordistrelease";
        constexpr static char const* lsb_release = "lsbrelease";
        constexpr static char const* ipaddress = "ipaddress";
        constexpr static char const* ipaddress6 = "ipaddress6";
        constexpr static char const* mtu = "mtu";
        constexpr static char const* netmask = "netmask";
        constexpr static char const* netmask6 = "netmask6";
        constexpr static char const* network = "network";
        constexpr static char const* network6 = "network6";
        constexpr static char const* macaddress = "macaddress";
        constexpr static char const* interfaces = "interfaces";
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_FACT_HPP_
