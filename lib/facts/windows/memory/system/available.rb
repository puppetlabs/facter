# frozen_string_literal: true

module Facter
  module Windows
    class MemorySystemAvailable
      FACT_NAME = 'memory.system.available'
      ALIASES = 'memoryfree'

      def call_the_resolver
        fact_value = Resolvers::Memory.resolve(:available_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
