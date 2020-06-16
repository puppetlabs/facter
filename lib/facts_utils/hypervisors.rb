# frozen_string_literal: true

module Facter
  module FactsUtils
    HYPERVISORS_HASH = { 'VMware' => 'vmware', 'VirtualBox' => 'virtualbox', 'Parallels' => 'parallels',
                         'KVM' => 'kvm', 'Virtual Machine' => 'hyperv', 'RHEV Hypervisor' => 'rhev',
                         'oVirt Node' => 'ovirt', 'HVM domU' => 'xenhvm', 'Bochs' => 'bochs', 'OpenBSD' => 'vmm',
                         'BHYVE' => 'bhyve' }.freeze
  end
end
