# frozen_string_literal: true

module Facter
  module Windows
    class ProcessorsModels
      FACT_NAME = 'processors.models'

      def call_the_resolver
        fact_value = Resolvers::ProcessorsResolver.resolve(:models)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
