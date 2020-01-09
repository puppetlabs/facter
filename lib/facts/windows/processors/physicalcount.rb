# frozen_string_literal: true

module Facter
  module Windows
    class ProcessorsPhysicalcount
      FACT_NAME = 'processors.physicalcount'
      ALIASES = 'physicalprocessorcount'

      def call_the_resolver
        fact_value = Resolvers::Processors.resolve(:physicalcount)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
