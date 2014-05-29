/**
 * @file
 * Declares the fact name constants.
 */
#ifndef FACTER_FACTS_FACT_HPP_
#define FACTER_FACTS_FACT_HPP_

namespace facter { namespace facts {

    /**
     * Stores the constant fact names.
     */
    struct fact
    {
        /**
         * The fact for kernel name.
         */
        constexpr static char const* kernel = "kernel";
        /**
         * The fact for kernel version.
         */
        constexpr static char const* kernel_version = "kernelversion";
        /**
         * The fact for kernel release.
         */
        constexpr static char const* kernel_release = "kernelrelease";
        /**
         * The fact for kernel major version.
         */
        constexpr static char const* kernel_major_version = "kernelmajversion";

        /**
         * The fact for operating system name.
         */
        constexpr static char const* operating_system = "operatingsystem";
        /**
         * The fact for operating system family name.
         */
        constexpr static char const* os_family = "osfamily";
        /**
         * The fact for operating system release.
         */
        constexpr static char const* operating_system_release = "operatingsystemrelease";
        /**
         * The fact for operating system major release.
         */
        constexpr static char const* operating_system_major_release = "operatingsystemmajrelease";

        /**
         * The fact for LSB distro id.
         */
        constexpr static char const* lsb_dist_id = "lsbdistid";
        /**
         * The fact for LSB distro release.
         */
        constexpr static char const* lsb_dist_release = "lsbdistrelease";
        /**
         * The fact for LSB distro codename.
         */
        constexpr static char const* lsb_dist_codename = "lsbdistcodename";
        /**
         * The fact for LSB distro description.
         */
        constexpr static char const* lsb_dist_description = "lsbdistdescription";
        /**
         * The fact for LSB distro major release.
         */
        constexpr static char const* lsb_dist_major_release = "lsbmajdistrelease";
        /**
         * The fact for LSB distro minor release.
         */
        constexpr static char const* lsb_dist_minor_release = "lsbminordistrelease";
        /**
         * The fact for LSB release.
         */
        constexpr static char const* lsb_release = "lsbrelease";

        /**
         * The fact for network hostname.
         */
        constexpr static char const* hostname = "hostname";
        /**
         * The fact for IPv4 address.
         */
        constexpr static char const* ipaddress = "ipaddress";
        /**
         * The fact for IPv6 address.
         */
        constexpr static char const* ipaddress6 = "ipaddress6";
        /**
         * The fact for interface MTU.
         */
        constexpr static char const* mtu = "mtu";
        /**
         * The fact for IPv4 netmask.
         */
        constexpr static char const* netmask = "netmask";
        /**
         * The fact for IPv6 netmask.
         */
        constexpr static char const* netmask6 = "netmask6";
        /**
         * The fact for IPv4 network.
         */
        constexpr static char const* network = "network";
        /**
         * The fact for IPv6 network.
         */
        constexpr static char const* network6 = "network6";
        /**
         * The fact for interface MAC address.
         */
        constexpr static char const* macaddress = "macaddress";
        /**
         * The fact for interface names.
         */
        constexpr static char const* interfaces = "interfaces";
        /**
         * The fact for domain name.
         */
        constexpr static char const* domain = "domain";
        /**
         * The fact for fully-qualified domain name (FQDN).
         */
        constexpr static char const* fqdn = "fqdn";
        /**
         * The fact for DHCP servers.
         */
        constexpr static char const* dhcp_servers = "dhcp_servers";

        /**
         * The fact for block device.
         */
        constexpr static char const* block_device = "blockdevice";
        /**
         * The fact for the list of block devices.
         */
        constexpr static char const* block_devices = "blockdevices";

        /**
         * The fact for processor descriptions.
         */
        constexpr static char const* processor = "processor";
        /**
         * The fact for logical processor count.
         */
        constexpr static char const* processor_count = "processorcount";
        /**
         * The fact for physical processor count.
         */
        constexpr static char const* physical_processor_count = "physicalprocessorcount";
        /**
         * The fact for processor instruction set architecture.
         */
        constexpr static char const* hardware_isa = "hardwareisa";
        /**
         * The fact for processor hardware model.
         */
        constexpr static char const* hardware_model = "hardwaremodel";

        /**
         * The fact for hardware architecture.
         */
        constexpr static char const* architecture = "architecture";
        /**
         * The fact for BIOS vendor.
         */
        constexpr static char const* bios_vendor = "bios_vendor";
        /**
         * The fact for BIOS version.
         */
        constexpr static char const* bios_version = "bios_version";
        /**
         * The fact for BIOS release date.
         */
        constexpr static char const* bios_release_date = "bios_release_date";
        /**
         * The fact for motherboard manufacturer.
         */
        constexpr static char const* board_manufacturer = "boardmanufacturer";
        /**
         * The fact for motherboard product name.
         */
        constexpr static char const* board_product_name = "boardproductname";
        /**
         * The fact for motherboard serial number.
         */
        constexpr static char const* board_serial_number = "boardserialnumber";
        /**
         * The fact for hardware manufacturer.
         */
        constexpr static char const* manufacturer = "manufacturer";
        /**
         * The fact for hardware product name.
         */
        constexpr static char const* product_name = "productname";
        /**
         * The fact for hardware serial number.
         */
        constexpr static char const* serial_number = "serialnumber";
        /**
         * The fact for hardware UUID.
         */
        constexpr static char const* product_uuid = "productuuid";
        /**
         * The fact for hardware chassis type.
         */
        constexpr static char const* chassis_type = "chassistype";

        /**
         * The fact for system uptime.
         */
        constexpr static char const* uptime = "uptime";
        /**
         * The fact for system uptime, in days.
         */
        constexpr static char const* uptime_days = "uptime_days";
        /**
         * The fact for system uptime, in hours.
         */
        constexpr static char const* uptime_hours = "uptime_hours";
        /**
         * The fact for system uptime, in seconds.
         */
        constexpr static char const* uptime_seconds = "uptime_seconds";

        /**
         * The fact for selinux state.
         */
        constexpr static char const* selinux = "selinux";
        /**
         * The fact for selinux enforcement state.
         */
        constexpr static char const* selinux_enforced = "selinux_enforced";
        /**
         * The fact for selinux policy version.
         */
        constexpr static char const* selinux_policyversion = "selinux_policyversion";
        /**
         * The fact for current selinux mode.
         */
        constexpr static char const* selinux_current_mode = "selinux_current_mode";
        /**
         * The fact for selinux config mode.
         */
        constexpr static char const* selinux_config_mode = "selinux_config_mode";
        /**
         * The fact for selinux config policy.
         */
        constexpr static char const* selinux_config_policy = "selinux_config_policy";

        /**
         * The fact for SSH DSA public key.
         */
        constexpr static char const* ssh_dsa_key = "sshdsakey";
        /**
         * The fact for SSH RSA public key.
         */
        constexpr static char const* ssh_rsa_key = "sshrsakey";
        /**
         * The fact for SSH ECDSA public key.
         */
        constexpr static char const* ssh_ecdsa_key = "sshecdsakey";
        /**
         * The fact for SSH ED25519 public key.
         */
        constexpr static char const* ssh_ed25519_key = "sshed25519key";
        /**
         * The fact for SSH fingerprint of the DSA public key.
         */
        constexpr static char const* sshfp_dsa = "sshfp_dsa";
        /**
         * The fact for SSH fingerprint of the RSA public key.
         */
        constexpr static char const* sshfp_rsa = "sshfp_rsa";
        /**
         * The fact for SSH fingerprint of the ECDSA public key.
         */
        constexpr static char const* sshfp_ecdsa = "sshfp_ecdsa";
        /**
         * The fact for SSH fingerprint of the ED25519 public key.
         */
        constexpr static char const* sshfp_ed25519 = "sshfp_ed25519";
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_FACT_HPP_
