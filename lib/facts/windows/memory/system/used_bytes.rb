# frozen_string_literal: true

module Facter
  module Windows
    class MemorySystemUsedBytes
      FACT_NAME = 'memory.system.used_bytes'

      def call_the_resolver
        fact_value = Resolvers::Memory.resolve(:used_bytes)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
