# frozen_string_literal: true

module Facts
  module Macosx
    class IsVirtual
      FACT_NAME = 'is_virtual'

      def call_the_resolver
        Facter::ResolvedFact.new(FACT_NAME, virtual?)
      end

      private

      def virtual?
        hypervisor_name != nil
      end

      def hypervisor_name
        model_identifier = Facter::Resolvers::SystemProfiler.resolve(:model_identifier)
        return 'vmware' if model_identifier&.start_with?('VMware')

        boot_rom_version = Facter::Resolvers::SystemProfiler.resolve(:boot_rom_version)
        return 'virtualbox' if boot_rom_version&.start_with?('VirtualBox')

        subsystem_vendor_id = Facter::Resolvers::SystemProfiler.resolve(:subsystem_vendor_id)
        return 'parallels' if subsystem_vendor_id&.start_with?('0x1ab8')
      end
    end
  end
end
