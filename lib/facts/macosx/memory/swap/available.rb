# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySwapAvailable
      FACT_NAME = 'memory.swap.available'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SwapMemory.resolve(:available_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
