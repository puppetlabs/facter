# frozen_string_literal: true

module Facter
  module Util
    module Facts
      HYPERVISORS_HASH = { 'VMware' => 'vmware', 'VirtualBox' => 'virtualbox', 'Parallels' => 'parallels',
                           'KVM' => 'kvm', 'Virtual Machine' => 'hyperv', 'RHEV Hypervisor' => 'rhev',
                           'oVirt Node' => 'ovirt', 'HVM domU' => 'xenhvm', 'Bochs' => 'bochs', 'OpenBSD' => 'vmm',
                           'BHYVE' => 'bhyve' }.freeze

      PHYSICAL_HYPERVISORS = %w[physical xen0 vmware_server vmware_workstation openvzhn vserver_host].freeze
    end
  end
end
