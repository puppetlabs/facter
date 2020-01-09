# frozen_string_literal: true

module Facter
  module Macosx
    class ProcessorsPhysicalCount
      FACT_NAME = 'processors.physicalcount'

      def call_the_resolver
        fact_value = Resolvers::Macosx::Processors.resolve(:physicalcount)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
