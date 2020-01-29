# frozen_string_literal: true

module Facter
  module Windows
    class MemorySystemTotalBytes
      FACT_NAME = 'memory.system.total_bytes'
      ALIASES = 'memorysize_mb'

      def call_the_resolver
        fact_value = Resolvers::Memory.resolve(:total_bytes)

        [ResolvedFact.new(FACT_NAME, fact_value),
         ResolvedFact.new(ALIASES, fact_value ? (fact_value / (1024.0 * 1024.0)).round(2) : nil, :legacy)]
      end
    end
  end
end
