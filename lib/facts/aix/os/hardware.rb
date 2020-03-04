# frozen_string_literal: true

module Facts
  module Aix
    module Os
      class Hardware
        FACT_NAME = 'os.hardware'

        def call_the_resolver
          fact_value = Facter::Resolvers::Hardware.resolve(:hardware)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
