# frozen_string_literal: true

module Facter
  module Sles
    class MemorySwapAvailableBytes
      FACT_NAME = 'memory.swap.available_bytes'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:swap_free)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
