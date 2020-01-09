# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySwapAvailableBytes
      FACT_NAME = 'memory.swap.available_bytes'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SwapMemory.resolve(:available_bytes)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
