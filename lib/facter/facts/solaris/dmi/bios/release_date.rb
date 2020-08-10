# frozen_string_literal: true

module Facts
  module Solaris
    module Dmi
      module Bios
        class ReleaseDate
          FACT_NAME = 'dmi.bios.release_date'
          ALIASES = 'bios_release_date'

          def call_the_resolver
            fact_value = nil
            fact_value = Facter::Resolvers::Solaris::Dmi.resolve(:bios_date) if isa == 'i386'
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end

          def isa
            Facter::Resolvers::Uname.resolve(:processor)
          end
        end
      end
    end
  end
end
