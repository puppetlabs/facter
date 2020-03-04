# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Bios
        class ReleaseDate
          FACT_NAME = 'dmi.bios.release_date'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:bios_date)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
