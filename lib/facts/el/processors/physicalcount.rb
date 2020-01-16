# frozen_string_literal: true

module Facter
  module El
    class ProcessorsPhysicalcount
      FACT_NAME = 'processors.physicalcount'

      def call_the_resolver
        fact_value = Resolvers::Linux::Processors.resolve(:physical_count)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
