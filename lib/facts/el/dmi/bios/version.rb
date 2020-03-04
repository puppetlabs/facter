# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Bios
        class Version
          FACT_NAME = 'dmi.bios.version'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:bios_version)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
