# frozen_string_literal: true

module Facter
  module Windows
    class MemorySystemTotal
      FACT_NAME = 'memory.system.total'
      ALIASES = 'memorysize'

      def call_the_resolver
        fact_value = Resolvers::Memory.resolve(:total_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
