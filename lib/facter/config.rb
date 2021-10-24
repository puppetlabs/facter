# frozen_string_literal: true

module Facter
  module Config
    unless defined?(OS_HIERARCHY)
      OS_HIERARCHY = [
        {
          'Linux' => [
            {
              'Debian' => [
                'Elementary',
                { 'Ubuntu' => [
                  'Linuxmint'
                ] },
                'Raspbian',
                'Devuan'
              ]
            },
            {
              'Rhel' => %w[
                Fedora
                Amzn
                Centos
                Ol
                Scientific
                Meego
                Oel
                Ovs
              ]
            },
            {
              'Sles' => %w[
                Opensuse
                Sled
              ]
            },
            'Gentoo',
            'Alpine',
            'Photon',
            'Slackware',
            'Mageia',
            'Openwrt'
          ]
        },
        {
          'Bsd' => [
            'Freebsd'
          ]
        },
        'Solaris',
        'Macosx',
        'Windows',
        'Aix'
      ].freeze
    end
    unless defined? FACT_GROUPS
      FACT_GROUPS = {
        'AIX NIM type' => [
          'nim_type'
        ],
        'EC2' => %w[
          ec2_metadata
          ec2_userdata
        ],
        'GCE' => [
          'gce'
        ],
        'Xen' => %w[
          xen
          xendomains
        ],
        'augeas' => %w[
          augeas
          augeasversion
        ],
        'desktop management interface' => %w[
          dmi
          bios_vendor
          bios_version
          bios_release_date
          boardassettag
          boardmanufacturer
          boardproductname
          boardserialnumber
          chassisassettag
          manufacturer
          productname
          serialnumber
          uuid
          chassistype
        ],
        'disks' => %w[
          blockdevices
          disks
        ],
        'file system' => %w[
          mountpoints
          filesystems
          partitions
        ],
        'fips' => [
          'fips_enabled'
        ],
        'hypervisors' => [
          'hypervisors'
        ],
        'id' => %w[
          id
          gid
          identity
        ],
        'kernel' => %w[
          kernel
          kernelversion
          kernelrelease
          kernelmajversion
        ],
        'load_average' => [
          'load_averages'
        ],
        'memory' => %w[
          memory
          memoryfree
          memoryfree_mb
          memorysize
          memorysize_mb
          swapfree
          swapfree_mb
          swapsize
          swapsize_mb
          swapencrypted
        ],
        'networking' => %w[
          networking
          hostname
          ipaddress
          ipaddress6
          netmask
          netmask6
          network
          network6
          scope6
          macaddress
          interfaces
          domain
          fqdn
          dhcp_servers
        ],
        'operating system' => %w[
          os
          operatingsystem
          osfamily
          operatingsystemrelease
          operatingsystemmajrelease
          hardwaremodel
          architecture
          lsbdistid
          lsbdistrelease
          lsbdistcodename
          lsbdistdescription
          lsbmajdistrelease
          lsbminordistrelease
          lsbrelease
          macosx_buildversion
          macosx_productname
          macosx_productversion
          macosx_productversion_major
          macosx_productversion_minor
          macosx_productversion_patch
          windows_edition_id
          windows_installation_type
          windows_product_name
          windows_release_id
          system32
          selinux
          selinux_enforced
          selinux_policyversion
          selinux_current_mode
          selinux_config_mode
          selinux_config_policy
        ],
        'path' => [
          'path'
        ],
        'processor' => %w[
          processors
          processorcount
          physicalprocessorcount
          hardwareisa
        ],
        'ssh' => %w[
          ssh
          sshdsakey
          sshrsakey
          sshecdsakey
          sshed25519key
          sshfp_dsa
          sshfp_rsa
          sshfp_ecdsa
          sshfp_ed25519
        ],
        'system profiler' => %w[
          system_profiler
          sp_boot_mode
          sp_boot_rom_version
          sp_boot_volume
          sp_cpu_type
          sp_current_processor_speed
          sp_kernel_version
          sp_l2_cache_core
          sp_l3_cache
          sp_local_host_name
          sp_machine_model
          sp_machine_name
          sp_number_processors
          sp_os_version
          sp_packages
          sp_physical_memory
          sp_platform_uuid
          sp_secure_vm
          sp_serial_number
          sp_smc_version_system
          sp_uptime
          sp_user_name
        ],
        'timezone' => [
          'timezone'
        ],
        'uptime' => %w[
          system_uptime
          uptime
          uptime_days
          uptime_hours
          uptime_seconds
        ],
        'virtualization' => %w[
          virtual
          is_virtual
          cloud
        ],
        'ldom' => [
          'ldom'
        ],
        'Solaris zone' => %w[
          zones
          zonename
          solaris_zones
        ],
        'ZFS' => %w[
          zfs_version
          zfs_featurenumbers
        ],
        'ZFS storage pool' => %w[
          zpool_version
          zpool_featureflags
          zpool_featurenumbers
        ],
        'legacy' => [
          'architecture',
          'augeasversion',
          'bios_release_date',
          'bios_vendor',
          'bios_version',
          'blockdevice_*_model',
          'blockdevice_*_size',
          'blockdevice_*_vendor',
          'blockdevices',
          'boardassettag',
          'boardmanufacturer',
          'boardproductname',
          'boardserialnumber',
          'chassisassettag',
          'chassistype',
          'dhcp_servers',
          'domain',
          'fqdn',
          'gid',
          'hardwareisa',
          'hardwaremodel',
          'hostname',
          'id',
          'interfaces',
          'ipaddress',
          'ipaddress_.*',
          'ipaddress_*',
          'ipaddress6',
          'ipaddress6_.*',
          'ipaddress6_*',
          'ldom_*',
          'lsbdistcodename',
          'lsbdistdescription',
          'lsbdistid',
          'lsbdistrelease',
          'lsbmajdistrelease',
          'lsbminordistrelease',
          'lsbrelease',
          'macaddress',
          'macaddress_.*',
          'macaddress_*',
          'macosx_buildversion',
          'macosx_productname',
          'macosx_productversion',
          'macosx_productversion_major',
          'macosx_productversion_minor',
          'macosx_productversion_patch',
          'manufacturer',
          'memoryfree',
          'memoryfree_mb',
          'memorysize',
          'memorysize_mb',
          'mtu_.*',
          'mtu_*',
          'netmask',
          'netmask_.*',
          'netmask_*',
          'netmask6',
          'netmask6_.*',
          'netmask6_*',
          'network',
          'network_.*',
          'network_*',
          'network6',
          'network6_.*',
          'network6_*',
          'operatingsystem',
          'operatingsystemmajrelease',
          'operatingsystemrelease',
          'osfamily',
          'physicalprocessorcount',
          'processor[0-9]+.*',
          'processorcount',
          'productname',
          'rubyplatform',
          'rubysitedir',
          'rubyversion',
          'scope6',
          'scope6_.*',
          'selinux',
          'selinux_config_mode',
          'selinux_config_policy',
          'selinux_current_mode',
          'selinux_enforced',
          'selinux_policyversion',
          'serialnumber',
          'sp_*',
          'sp_boot_mode',
          'sp_boot_rom_version',
          'sp_boot_volume',
          'sp_cpu_type',
          'sp_current_processor_speed',
          'sp_kernel_version',
          'sp_l2_cache_core',
          'sp_l3_cache',
          'sp_local_host_name',
          'sp_machine_model',
          'sp_machine_name',
          'sp_number_processors',
          'sp_os_version',
          'sp_packages',
          'sp_physical_memory',
          'sp_platform_uuid',
          'sp_secure_vm',
          'sp_serial_number',
          'sp_smc_version_system',
          'sp_uptime',
          'sp_user_name',
          'ssh.*key',
          'ssh*key',
          'sshfp_.*',
          'sshfp_*',
          'swapencrypted',
          'swapfree',
          'swapfree_mb',
          'swapsize',
          'swapsize_mb',
          'system32',
          'uptime',
          'uptime_days',
          'uptime_hours',
          'uptime_seconds',
          'uuid',
          'windows_edition_id',
          'windows_installation_type',
          'windows_product_name',
          'windows_release_id',
          'xendomains',
          'zone_*_brand',
          'zone_*_id',
          'zone_*_iptype',
          'zone_*_name',
          'zone_*_path',
          'zone_*_status',
          'zone_*_uuid',
          'zonename',
          'zones'
        ]
      }.freeze
    end
  end
end
