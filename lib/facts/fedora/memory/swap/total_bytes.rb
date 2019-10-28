# frozen_string_literal: true

module Facter
  module Fedora
    class MemorySwapTotalBytes
      FACT_NAME = 'memory.swap.total_bytes'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:swap_total)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
