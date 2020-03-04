# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Bios
        class Vendor
          FACT_NAME = 'dmi.bios.vendor'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
