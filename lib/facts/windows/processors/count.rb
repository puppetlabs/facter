# frozen_string_literal: true

module Facter
  module Windows
    class ProcessorsCount
      FACT_NAME = 'processors.count'

      def call_the_resolver
        fact_value = Resolvers::Processors.resolve(:count)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
