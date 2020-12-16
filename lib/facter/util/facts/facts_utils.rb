# frozen_string_literal: true

module Facter
  module Util
    module Facts
      HYPERVISORS_HASH = { 'VMware' => 'vmware', 'VirtualBox' => 'virtualbox', 'Parallels' => 'parallels',
                           'KVM' => 'kvm', 'Virtual Machine' => 'hyperv', 'RHEV Hypervisor' => 'rhev',
                           'oVirt Node' => 'ovirt', 'HVM domU' => 'xenhvm', 'Bochs' => 'bochs', 'OpenBSD' => 'vmm',
                           'BHYVE' => 'bhyve' }.freeze

      PHYSICAL_HYPERVISORS = %w[physical xen0 vmware_server vmware_workstation openvzhn vserver_host].freeze
      REDHAT_FAMILY = %w[redhat rhel fedora centos scientific ascendos cloudlinux psbm
                         oraclelinux ovs oel amazon xenserver xcp-ng virtuozzo photon].freeze
      DEBIAN_FAMILY = %w[debian ubuntu huaweios linuxmint devuan kde].freeze
      SUSE_FAMILY = %w[sles sled suse].freeze
      GENTOO_FAMILY = ['gentoo'].freeze
      ARCH_FAMILY = %w[arch manjaro].freeze
      MANDRAKE_FAMILY = %w[mandrake mandriva mageia].freeze
      FAMILY_HASH = { 'RedHat' => REDHAT_FAMILY, 'Debian' => DEBIAN_FAMILY, 'Suse' => SUSE_FAMILY,
                      'Gentoo' => GENTOO_FAMILY, 'Archlinux' => ARCH_FAMILY, 'Mandrake' => MANDRAKE_FAMILY }.freeze

      class << self
        def discover_family(os)
          FAMILY_HASH.each { |key, array_value| return key if array_value.any? { |os_flavour| os =~ /#{os_flavour}/i } }
          os
        end
      end
    end
  end
end
