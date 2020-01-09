# frozen_string_literal: true

module Facter
  module Macosx
    class MemorySwapEncrypted
      FACT_NAME = 'memory.swap.encrypted'

      def call_the_resolver
        fact_value = Resolvers::Macosx::SwapMemory.resolve(:encrypted)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
