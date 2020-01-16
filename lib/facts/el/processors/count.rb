# frozen_string_literal: true

module Facter
  module El
    class ProcessorsCount
      FACT_NAME = 'processors.count'

      def call_the_resolver
        fact_value = Resolvers::Linux::Processors.resolve(:processors)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
