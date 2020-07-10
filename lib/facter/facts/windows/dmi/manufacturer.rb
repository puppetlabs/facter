# frozen_string_literal: true

module Facts
  module Windows
    module Dmi
      class Manufacturer
        FACT_NAME = 'dmi.manufacturer'
        ALIASES = 'manufacturer'

        def call_the_resolver
          fact_value = Facter::Resolvers::DMIBios.resolve(:manufacturer)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
