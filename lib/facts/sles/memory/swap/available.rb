# frozen_string_literal: true

module Facter
  module Sles
    class MemorySwapAvailable
      FACT_NAME = 'memory.swap.available'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:swap_free)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
