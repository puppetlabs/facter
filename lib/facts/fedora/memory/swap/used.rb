# frozen_string_literal: true

module Facter
  module Fedora
    class MemorySwapUsed
      FACT_NAME = 'memory.swap.used'

      def call_the_resolver
        fact_value = Resolvers::Linux::Memory.resolve(:swap_used_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
