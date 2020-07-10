# frozen_string_literal: true

module Facts
  module Windows
    module Processors
      class Models
        FACT_NAME = 'processors.models'

        def call_the_resolver
          fact_value = Facter::Resolvers::Processors.resolve(:models)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
