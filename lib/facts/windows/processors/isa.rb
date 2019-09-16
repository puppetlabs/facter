# frozen_string_literal: true

module Facter
  module Windows
    class ProcessorsIsa
      FACT_NAME = 'processors.isa'

      def call_the_resolver
        fact_value = Resolvers::ProcessorsResolver.resolve(:isa)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
