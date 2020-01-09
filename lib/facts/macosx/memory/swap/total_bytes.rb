# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySwapTotalBytes
      FACT_NAME = 'memory.swap.total_bytes'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SwapMemory.resolve(:total_bytes)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
