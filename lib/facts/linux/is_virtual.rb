# frozen_string_literal: true

module Facts
  module Linux
    class IsVirtual
      FACT_NAME = 'is_virtual'
      HYPERVISORS_HASH = { 'VMware' => 'vmware', 'VirtualBox' => 'virtualbox', 'Parallels' => 'parallels',
                           'KVM' => 'kvm', 'Virtual Machine' => 'hyperv', 'RHEV Hypervisor' => 'rhev',
                           'oVirt Node' => 'ovirt', 'HVM domU' => 'xenhvm', 'Bochs' => 'bochs', 'OpenBSD' => 'vmm',
                           'BHYVE' => 'bhyve' }.freeze
      PHYSICAL_HYPERVISORS = %w[physical xen0 vmware_server vmware_workstation openvzhn vserver_host].freeze

      def call_the_resolver # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        fact_value = check_docker_lxc || check_gce || retrieve_from_virt_what || check_vmware
        fact_value ||= check_open_vz || check_vserver || check_xen || check_other_facts || check_lspci || 'physical'

        Facter::ResolvedFact.new(FACT_NAME, check_if_virtual(fact_value))
      end

      def check_gce
        bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        'gce' if bios_vendor&.include?('Google')
      end

      def check_docker_lxc
        Facter::Resolvers::DockerLxc.resolve(:vm)
      end

      def check_vmware
        Facter::Resolvers::Vmware.resolve(:vm)
      end

      def retrieve_from_virt_what
        Facter::Resolvers::VirtWhat.resolve(:vm)
      end

      def check_open_vz
        Facter::Resolvers::OpenVz.resolve(:vm)
      end

      def check_vserver
        Facter::Resolvers::VirtWhat.resolve(:vserver)
      end

      def check_xen
        Facter::Resolvers::Xen.resolve(:vm)
      end

      def check_other_facts
        product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
        bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        return 'kvm' if bios_vendor&.include?('Amazon EC2')
        return unless product_name

        HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }
      end

      def check_lspci
        Facter::Resolvers::Lspci.resolve(:vm)
      end

      def check_if_virtual(found_vm)
        PHYSICAL_HYPERVISORS.count(found_vm).zero?
      end
    end
  end
end
