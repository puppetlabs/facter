# frozen_string_literal: true

module Facts
  module Aix
    module Os
      class Hardware
        FACT_NAME = 'os.hardware'
        ALIASES = 'hardwaremodel'

        def call_the_resolver
          fact_value = Facter::Resolvers::Hardware.resolve(:hardware)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
