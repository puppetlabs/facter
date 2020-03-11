# frozen_string_literal: true

module Facts
  module Sles
    module Os
      class Hardware
        FACT_NAME = 'os.hardware'
        ALIASES = 'hardwaremodel'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:machine)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
