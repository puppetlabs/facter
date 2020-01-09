# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySwapTotal
      FACT_NAME = 'memory.swap.total'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SwapMemory.resolve(:total_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
