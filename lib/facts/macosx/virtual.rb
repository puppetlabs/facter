# frozen_string_literal: true

module Facts
  module Macosx
    class Virtual
      FACT_NAME = 'virtual'

      def call_the_resolver
        fact_value = check_vmware || check_virtualbox || check_parallels

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end

      private

      def check_vmware
        model_identifier = Facter::Resolvers::SystemProfiler.resolve(:model_identifier)
        return 'vmware' if model_identifier&.start_with?('VMware')
      end

      def check_virtualbox
        boot_rom_version = Facter::Resolvers::SystemProfiler.resolve(:boot_rom_version)
        return 'virtualbox' if boot_rom_version&.start_with?('VirtualBox')
      end

      def check_parallels
        subsystem_vendor_id = Facter::Resolvers::SystemProfiler_2.resolve(:subsystem_vendor_id)
        return 'parallels' if subsystem_vendor_id&.start_with?('0x1ab8')
      end
    end
  end
end
