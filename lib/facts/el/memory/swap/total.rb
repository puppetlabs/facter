# frozen_string_literal: true

module Facter
  module El
    class MemorySwapTotal
      FACT_NAME = 'memory.swap.total'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:swap_total)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
