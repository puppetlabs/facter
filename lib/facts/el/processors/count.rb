# frozen_string_literal: true

module Facts
  module El
    module Processors
      class Count
        FACT_NAME = 'processors.count'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Processors.resolve(:processors)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
