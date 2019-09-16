# frozen_string_literal: true

module Facter
  module Windows
    class ProcessorsPhysicalcount
      FACT_NAME = 'processors.physicalcount'

      def call_the_resolver
        fact_value = Resolver::ProcessorsResolver.resolve(:physicalcount)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
