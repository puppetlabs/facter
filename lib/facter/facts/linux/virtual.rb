# frozen_string_literal: true

module Facts
  module Linux
    class Virtual
      FACT_NAME = 'virtual'

      def initialize
        @log = Facter::Log.new(self)
      end

      def call_the_resolver # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        @log.debug('Linux Virtual Resolver')

        fact_value = check_docker_lxc || check_gce || retrieve_from_virt_what || check_vmware
        fact_value ||= check_open_vz || check_vserver || check_xen || check_other_facts || check_lspci || 'physical'

        @log.debug("Fact value is: #{fact_value}")

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end

      def check_gce
        @log.debug('Checking GCE')
        bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        'gce' if bios_vendor&.include?('Google')
      end

      def check_docker_lxc
        @log.debug('Checking Docker and LXC')
        Facter::Resolvers::Containers.resolve(:vm)
      end

      def check_vmware
        @log.debug('Checking VMware')
        Facter::Resolvers::Vmware.resolve(:vm)
      end

      def retrieve_from_virt_what
        @log.debug('Checking virtual_what')
        Facter::Resolvers::VirtWhat.resolve(:vm)
      end

      def check_open_vz
        @log.debug('Checking OpenVZ')
        Facter::Resolvers::OpenVz.resolve(:vm)
      end

      def check_vserver
        @log.debug('Checking VServer')
        Facter::Resolvers::VirtWhat.resolve(:vserver)
      end

      def check_xen
        @log.debug('Checking XEN')
        Facter::Resolvers::Xen.resolve(:vm)
      end

      def check_other_facts
        @log.debug('Checking others')
        product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
        bios_vendor =  Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
        return 'kvm' if bios_vendor&.include?('Amazon EC2')
        return unless product_name

        Facter::FactsUtils::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

        nil
      end

      def check_lspci
        @log.debug('Checking lspci')
        Facter::Resolvers::Lspci.resolve(:vm)
      end
    end
  end
end
