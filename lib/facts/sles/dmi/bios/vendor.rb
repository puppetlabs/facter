# frozen_string_literal: true

module Facts
  module Sles
    module Dmi
      module Bios
        class Vendor
          FACT_NAME = 'dmi.bios.vendor'
          ALIASES = 'bios_vendor'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
