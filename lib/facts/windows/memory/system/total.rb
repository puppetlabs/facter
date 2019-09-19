# frozen_string_literal: true

module Facter
  module Windows
    class MemorySystemTotal
      FACT_NAME = 'memory.system.total'

      def call_the_resolver
        fact_value = Resolvers::MemoryResolver.resolve(:total_bytes)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
