# frozen_string_literal: true

module Facts
  module Linux
    class Gce
      FACT_NAME = 'gce'

      def call_the_resolver
        bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)

        fact_value = bios_vendor&.include?('Google') ? Facter::Resolvers::Gce.resolve(:metadata) : nil
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
