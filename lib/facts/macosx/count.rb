# frozen_string_literal: true

module Facter
  module Macosx
    class ProcessorsCount
      FACT_NAME = 'processors.count'

      def call_the_resolver
        fact_value = Resolvers::Macosx::Processors.resolve(:logicalcount)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
