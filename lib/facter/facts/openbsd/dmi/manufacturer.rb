# frozen_string_literal: true

module Facts
  module Openbsd
    module Dmi
      class Manufacturer
        FACT_NAME = 'dmi.manufacturer'
        ALIASES = 'manufacturer'

        def call_the_resolver
          fact_value = Facter::Resolvers::Openbsd::DmiBios.resolve(:sys_vendor)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
