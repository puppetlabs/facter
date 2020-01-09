# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySwapCapacity
      FACT_NAME = 'memory.swap.capacity'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SwapMemory.resolve(:capacity)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
