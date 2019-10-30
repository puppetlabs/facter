# frozen_string_literal: true

module Facter
  module Sles
    class MemorySwapCapacity
      FACT_NAME = 'memory.swap.capacity'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:swap_capacity)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
